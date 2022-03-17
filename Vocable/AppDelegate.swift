//
//  AppDelegate.swift
//  Vocable AAC
//
//  Created by Duncan Lewis on 6/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import CoreData
import Combine
import AVFoundation
import VocableListenCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? {
        get {
            gazeableWindow
        }
        // swiftlint:disable unused_setter_value
        set {

        }
    }

    // This is to silence the console warning "The app delegate must implement the window property if it wants to use a main storyboard file"
    // It appears to complain if the window property is not explicitly typed as UIWindow
    private lazy var gazeableWindow = HeadGazeWindow(frame: UIScreen.main.bounds)

    var gazeTrackingWindow: UIHeadGazeTrackingWindow?
    var cursorWindow: UIHeadGazeCursorWindow? {
        didSet {
            gazeableWindow.cursorView = cursorWindow?.cursorViewController.virtualCursorView
        }
    }

    private var disposables: [AnyCancellable] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if !AppConfig.isHeadTrackingSupported {
            AppConfig.isHeadTrackingEnabled = false
        }

        if ProcessInfo.processInfo.arguments.contains("resetAppDataOnLaunch") {
            print("-resetAppDataOnLaunch detected, resetting app data")
            let resetController = AppResetController()
            if resetController.performReset() {
                print("\t...Succeeded")
            } else {
                print("\t...Reset failed")
            }
        }

        // Ensure that the persistent store has the current
        // default presets before presenting UI
        updatePersistentStoreForCurrentLanguagePreferences()
        
        addObservers()

        // Warm up the speech engine to prevent lag on first invocation
        AVSpeechSynthesizer.shared.speak("", language: "en")

        application.isIdleTimerDisabled = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(localeDidChange(_:)),
                                               name: NSLocale.currentLocaleDidChangeNotification,
                                               object: nil)

        AppConfig.$isHeadTrackingEnabled.receive(on: DispatchQueue.main).sink { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.installTrackingWindowsIfNeeded()
            } else {
                self.removeTrackingWindowsIfNeeded()
            }
        }.store(in: &disposables)

        _ = SpeechRecognitionController.shared

        AppConfig.$isListeningModeEnabled
            .removeDuplicates()
            .sink { isEnabled in
                if #available(iOS 14.0, *), isEnabled {
                    VLClassifier.prepare()
                }
            }.store(in: &disposables)

        return true
    }

    private func installTrackingWindowsIfNeeded() {
        if gazeTrackingWindow == nil {
            gazeTrackingWindow = UIHeadGazeTrackingWindow(frame: UIScreen.main.bounds)
            gazeTrackingWindow?.windowLevel = UIWindow.Level(rawValue: -1)
            gazeTrackingWindow?.isHidden = false
        }
        if cursorWindow == nil {
            cursorWindow = UIHeadGazeCursorWindow(frame: UIScreen.main.bounds)
            cursorWindow?.windowLevel = UIWindow.Level(rawValue: 1)
            cursorWindow?.isHidden = false
        }
    }

    private func removeTrackingWindowsIfNeeded() {
        gazeTrackingWindow?.isHidden = true
        gazeTrackingWindow = nil

        cursorWindow?.isHidden = true
        cursorWindow = nil
    }

    @objc
    private func localeDidChange(_ note: Notification?) {
        updatePersistentStoreForCurrentLanguagePreferences()
    }

    private func updatePersistentStoreForCurrentLanguagePreferences() {
        let container = NSPersistentContainer.shared
        if let url = container.persistentStoreCoordinator.persistentStores.first?.url?.absoluteString.removingPercentEncoding {
            print("NSPersistentStore URL: \(url)")
        }

        let context = container.viewContext

        guard let presets = TextPresets.presets else {
            let message = NSLocalizedString("debug.assertion.presets_file_not_found",
                                            comment: "Debugging error message for when preloaded content is not found")
            assertionFailure(message)
            return
        }

        do {

            try createPrescribedEntities(in: context, with: presets)
            try deleteOrphanedPhrases(in: context, with: presets)
            try deleteOrphanedCategories(in: context, with: presets)
            try deleteLegacyUserFavoritesCategoryIfNeeded(in: context)
            try Category.updateAllOrdinalValues(in: context)

            try context.save()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(headTrackingDisabled(_:)), name: .headTrackingDisabled, object: nil)
    }
    
    @objc private func applicationDidLoseGaze(_ sender: Any?) {
         gazeableWindow.presentHeadTrackingErrorToastIfNeeded()
    }

    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        ToastWindow.shared.dismissPersistentWarning()
    }
    
    @objc private func headTrackingDisabled(_ sender: Any?) {
        ToastWindow.shared.dismissPersistentWarning()
    }

    private func deleteOrphanedPhrases(in context: NSManagedObjectContext, with presets: PresetData) throws {

        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = {
            let identifiers = Set(presets.phrases.map { $0.id })
            let isNotUserGenerated = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, false)
            let identifierInSet = NSComparisonPredicate(\Phrase.identifier, .in, identifiers)
            let identifierNotInSet = NSCompoundPredicate(notPredicateWithSubpredicate: identifierInSet)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [isNotUserGenerated, identifierNotInSet])
        }()

        let results = try context.fetch(request)
        for phrase in results {
            context.delete(phrase)
        }
    }

    private func deleteOrphanedCategories(in context: NSManagedObjectContext, with presets: PresetData) throws {

        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = {
            let identifiers = Set(presets.categories.map { $0.id })
            let isNotUserGenerated = NSComparisonPredicate(\Category.isUserGenerated, .equalTo, false)
            let identifierInSet = NSComparisonPredicate(\Category.identifier, .in, identifiers)
            let identifierNotInSet = NSCompoundPredicate(notPredicateWithSubpredicate: identifierInSet)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [isNotUserGenerated, identifierNotInSet])
        }()

        let results = try context.fetch(request)
        for phrase in results {
            context.delete(phrase)
        }
    }

    private func deleteLegacyUserFavoritesCategoryIfNeeded(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = {
            // Legacy favorites category was .isUserGenerated = true with identifier = localized version
            // of "My Sayings." Going forward, all identifiers for Phrases/Categories are prefixed, so
            // we can use that to isolate the legacy category entry
            let isUserGenerated = NSComparisonPredicate(\Category.isUserGenerated, .equalTo, true)
            let identifierPrefixed = NSComparisonPredicate(\Category.identifier, .beginsWith, "user_")
            let identifierNotPrefixed = NSCompoundPredicate(notPredicateWithSubpredicate: identifierPrefixed)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [isUserGenerated, identifierNotPrefixed])
        }()

        let results = try context.fetch(request)
        for category in results {
            context.delete(category)
        }
    }

    private func createPrescribedEntities(in context: NSManagedObjectContext, with presets: PresetData) throws {

        try updateDefaultCategories(in: context, withPresets: presets)
        try updateDefaultPhrases(in: context, withPresets: presets)
        try updateCategoryForUserGeneratedPhrases(in: context)

    }

    private func updateDefaultCategories(in context: NSManagedObjectContext, withPresets presets: PresetData) throws {
        for presetCategory in presets.categories {
            let category = Category.fetchOrCreate(in: context, matching: presetCategory.id)
            category.name = presetCategory.utterance
            category.languageCode = presetCategory.languageCode
            if category.isInserted {
                category.isHidden = presetCategory.hidden
            }
        }
    }

    private func updateDefaultPhrases(in context: NSManagedObjectContext, withPresets presets: PresetData) throws {
        for presetPhrase in presets.phrases {

            let phrase = Phrase.fetchOrCreate(in: context, matching: presetPhrase.id)
            phrase.utterance = presetPhrase.utterance
            phrase.languageCode = presetPhrase.languageCode
            
            for identifier in presetPhrase.categoryIds {
                if let category = Category.fetchObject(in: context, matching: identifier) {
                    phrase.category = category
                    category.addToPhrases(phrase)
                }
            }
        }
    }

    private func updateCategoryForUserGeneratedPhrases(in context: NSManagedObjectContext) throws {
        let mySayingsCategory = Category.fetch(.userFavorites, in: context)
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()

        let firstPredicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)
        let secondPredicate = NSComparisonPredicate(\Phrase.category?.isUserGenerated, .equalTo, false)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [firstPredicate, secondPredicate])

        let phraseResults = try context.fetch(request)

        for phrase in phraseResults {
            phrase.category = mySayingsCategory
            mySayingsCategory.addToPhrases(phrase)
        }
    }
}
