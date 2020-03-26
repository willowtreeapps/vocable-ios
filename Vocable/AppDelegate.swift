//
//  AppDelegate.swift
//  Vocable AAC
//
//  Created by Duncan Lewis on 6/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationWindow: NotificationWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Ensure that the persistent store has the current
        // default presets before presenting UI
        preparePersistentStore()
        
        addObservers()
        notificationWindow = NotificationWindow(frame: UIScreen.main.bounds)
        notificationWindow?.isHidden = true
        
        application.isIdleTimerDisabled = true
        let window = HeadGazeWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    private func preparePersistentStore() {
        let container = NSPersistentContainer.shared
        if let url = container.persistentStoreCoordinator.persistentStores.first?.url?.absoluteString.removingPercentEncoding {
            print("NSPersistentStore URL: \(url)")
        }
        let context = container.viewContext
        deleteExistingPrescribedEntities(in: context)
        createPrescribedEntities(in: context)

        do {
            try context.save()
        } catch {
            assertionFailure("Core Data save failure: \(error)")
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .headTrackingDisabled, object: nil)
    }
    
    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        handleWarning(shouldDisplay: true)
    }
    
    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        handleWarning(shouldDisplay: false)
    }
    
    @objc private func headTrackingDisabled(_ sender: Any?) {
        handleWarning(shouldDisplay: false)
    }
    
    private func handleWarning(shouldDisplay: Bool) {
        notificationWindow?.handleWarning(shouldDisplay: shouldDisplay)
    }

    private func deleteExistingPrescribedEntities(in context: NSManagedObjectContext) {

        let phraseRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        phraseRequest.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, false)
        let phraseResults = (try? context.fetch(phraseRequest)) ?? []
        for phrase in phraseResults {
            context.delete(phrase)
        }

        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryRequest.predicate = NSComparisonPredicate(\Category.isUserGenerated, .equalTo, false)
        let categoryResults = (try? context.fetch(categoryRequest)) ?? []
        for category in categoryResults {
            context.delete(category)
        }
    }

    private func createPrescribedEntities(in context: NSManagedObjectContext) {

        // Create entities that are provided implicitly
        for presetCategory in TextPresets.presetsByCategory {

            let category = Category.fetchOrCreate(in: context, matching: presetCategory.title)
            category.creationDate = Date()
            category.name = presetCategory.title

            if category.name == TextPresets.savedSayingsIdentifier {
                category.isUserGenerated = true
            }

            for preset in presetCategory.presets.reversed() {
                let phrase = Phrase.fetchOrCreate(in: context, matching: preset)
                phrase.creationDate = Date()
                phrase.utterance = preset
                phrase.addToCategories(category)
            }
        }
    }
}
