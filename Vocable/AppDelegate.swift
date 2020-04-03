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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Ensure that the persistent store has the current
        // default presets before presenting UI
        preparePersistentStore()

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

        let context = container.newBackgroundContext()
        deleteExistingPrescribedEntities(in: context)
        createPrescribedEntities(in: context)

        do {
            try context.save()
        } catch {
            assertionFailure("Core Data save failure: \(error)")
        }
    }

    private func deleteExistingPrescribedEntities(in context: NSManagedObjectContext) {
//        guard let presetJSON = TextPresets.presets else {
//            assertionFailure("No presets found")
//            return
//        }

//        let phraseRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
//        phraseRequest.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, false)
//
//        do {
//            let phraseResults = try context.fetch(phraseRequest)
//            for phrase in phraseResults where !phraseResults.contains(presetJSON.phrases) {
//                context.delete(phrase)
//            }
//
//        } catch {
//            assertionFailure(error.localizedDescription)
//        }

//        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
//        categoryRequest.predicate = NSComparisonPredicate(\Category.isUserGenerated, .equalTo, false)
//
//        do {
//            let categoryResults = try context.fetch(categoryRequest)
//            for category in categoryResults where !phraseResults.contains(presetJSON.phrases) {
//                context.delete(category)
//            }
//
//        } catch {
//            assertionFailure(error.localizedDescription)
//        }


    }

    private func createPrescribedEntities(in context: NSManagedObjectContext) {
        guard let presetJSON = TextPresets.presets else {
            assertionFailure("No presets found")
            return
        }

        let orderedLanguages = Array(Locale.preferredLanguages.map {
            return [$0, Locale.components(fromIdentifier: $0)[String(CFLocaleKey.languageCode.rawValue)]!]
        }.joined()) + ["en"]

        for presetCategory in presetJSON.categories {
            let supportLanguages = Set(presetCategory.localizedName.keys)
            guard let languageCode = orderedLanguages.first(where: supportLanguages.contains) else {
                continue
            }

            let category = Category.fetchOrCreate(in: context, matching: presetCategory.id)
            category.isUserGenerated = false
            category.name = presetCategory.localizedName[languageCode]
            category.languageCode = languageCode

            if category.isInserted {
                category.creationDate = Date()
            }
        }

        for presetPhrase in presetJSON.phrases {
            let supportLanguages = Set(presetPhrase.localizedUtterance.keys)
            guard let languageCode = orderedLanguages.first(where: supportLanguages.contains) else {
                continue
            }

            let phrase = Phrase.fetchOrCreate(in: context, matching: presetPhrase.id)
            phrase.isUserGenerated = false
            phrase.utterance = presetPhrase.localizedUtterance[languageCode]
            phrase.languageCode = languageCode

            if phrase.isInserted {
                phrase.creationDate = Date()
            }

            for identifier in presetPhrase.categoryIds {
                if let category = Category.fetchObject(in: context, matching: identifier) {
                    phrase.addToCategories(category)
                    category.addToPhrases(phrase)
                }
            }
        }

        if let mySayingsCategory = Category.fetchObject(in: context, matching: TextPresets.savedSayingsIdentifier) {
            let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
            request.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)

            do {
                let phraseResults = try context.fetch(request)

                for phrase in phraseResults {
                    phrase.addToCategories(mySayingsCategory)
                }

            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

    }

}
