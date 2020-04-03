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
        updatePersistentStoreForCurrentLanguagePreferences()
        
        addObservers()

        application.isIdleTimerDisabled = true
        let window = HeadGazeWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
        self.window = window

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(localeDidChange(_:)),
                                               name: NSLocale.currentLocaleDidChangeNotification,
                                               object: nil)
        return true
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
            assertionFailure("No presets found")
            return
        }

        do {

            try createPrescribedEntities(in: context, with: presets)
            try deleteOrphanedPhrases(in: context, with: presets)
            try deleteOrphanedCategories(in: context, with: presets)
            try deleteLegacyUserFavoritesCategoryIfNeeded(in: context)
            try updateOrdinalValuesForCategories(in: context)

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
        ToastWindow.shared.presentPersistantWarning(with: NSLocalizedString("Please move closer to the device.", comment: "Warning title when head tracking is lost."))
    }
    
    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        ToastWindow.shared.dismissPersistantWarning()
    }
    
    @objc private func headTrackingDisabled(_ sender: Any?) {
        ToastWindow.shared.dismissPersistantWarning()
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

        let orderedLanguages = Array(Locale.preferredLanguages.map { regionalLanguage -> [String] in
            let rootLanguage = Locale(identifier: regionalLanguage).languageCode
            let languages = [regionalLanguage, rootLanguage].compactMap { $0 }
            return languages // If no match exists for the regional language code, fall-back to the main language code
        }.joined()) + [AppConfig.defaultLanguageCode] // Ensure the default language code is always in the list so the UI will be populated with *something*

        try updateDefaultCategories(in: context, withPresets: presets, orderedLanguages: orderedLanguages)
        try updateDefaultPhrases(in: context, withPresets: presets, orderedLanguages: orderedLanguages)
        try updateCategoryForUserGeneratedPhrases(in: context)

    }

    private func updateDefaultCategories(in context: NSManagedObjectContext, withPresets presets: PresetData, orderedLanguages: [String]) throws {
        for presetCategory in presets.categories {
            let supportLanguages = Set(presetCategory.localizedName.keys)
            guard let languageCode = orderedLanguages.first(where: supportLanguages.contains) else {
                assertionFailure("Matching language not found for category \(presetCategory)")
                continue
            }

            let category = Category.fetchOrCreate(in: context, matching: presetCategory.id)
            category.name = presetCategory.localizedName[languageCode]
            category.languageCode = languageCode
            if category.isInserted {
                category.isHidden = presetCategory.hidden
            }
        }
    }

    private func updateDefaultPhrases(in context: NSManagedObjectContext, withPresets presets: PresetData, orderedLanguages: [String]) throws {
        for presetPhrase in presets.phrases {
            let supportLanguages = Set(presetPhrase.localizedUtterance.keys)
            guard let languageCode = orderedLanguages.first(where: supportLanguages.contains) else {
                assertionFailure("Matching language not found for phrase \(presetPhrase)")
                continue
            }

            let phrase = Phrase.fetchOrCreate(in: context, matching: presetPhrase.id)
            phrase.utterance = presetPhrase.localizedUtterance[languageCode]
            phrase.languageCode = languageCode

            for identifier in presetPhrase.categoryIds {
                if let category = Category.fetchObject(in: context, matching: identifier) {
                    phrase.addToCategories(category)
                    category.addToPhrases(phrase)
                }
            }
        }
    }

    private func updateCategoryForUserGeneratedPhrases(in context: NSManagedObjectContext) throws {
        guard let mySayingsCategory = Category.fetchObject(in: context, matching: TextPresets.savedSayingsIdentifier) else {
            assertionFailure("User generated category not found")
            return
        }
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)

        let phraseResults = try context.fetch(request)

        for phrase in phraseResults {
            phrase.addToCategories(mySayingsCategory)
            mySayingsCategory.addToPhrases(phrase)
        }
    }

    private func updateOrdinalValuesForCategories(in context: NSManagedObjectContext) throws {

        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSComparisonPredicate(\Category.isUserGenerated, .equalTo, false)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.ordinal, ascending: true),
            NSSortDescriptor(keyPath: \Category.creationDate, ascending: true)
        ]
        let results = try context.fetch(request)
        for (index, category) in results.enumerated() {
            category.ordinal = Int32(index)
        }
    }
}
