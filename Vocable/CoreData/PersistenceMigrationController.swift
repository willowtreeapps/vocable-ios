//
//  PersistenceMigrationController.swift
//  Vocable
//
//  Created by Chris Stroud on 3/17/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import CoreData

struct PersistenceMigrationController {

    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer = .shared) {
        self.persistentContainer = persistentContainer
    }

    @discardableResult
    func performMigrationForCurrentLanguagePreferences(using presetData: PresetData? = TextPresets.presets) -> Bool {

        if let url = persistentContainer.persistentStoreCoordinator.persistentStores.first?.url?.absoluteString.removingPercentEncoding {
            print("[PersistenceMigrationController] persistentStore URL: \(url)")
        }

        let context = persistentContainer.viewContext

        guard let presets = presetData else {
            let message = NSLocalizedString("debug.assertion.presets_file_not_found",
                                            comment: "Debugging error message for when preloaded content is not found")
            assertionFailure(message)
            return false
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
            return false
        }

        return true
    }

    private func deleteOrphanedPhrases(in context: NSManagedObjectContext, with presets: PresetData) throws {

        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = {
            let presetPhraseIdentifiers = Set(presets.phrases.map(\.id))
            let isNotUserGenerated = !Predicate(\Phrase.isUserGenerated)
            let isNotPresetPhrase = !Predicate(\Phrase.identifier, isContainedIn: presetPhraseIdentifiers)
            return isNotUserGenerated && isNotPresetPhrase
        }()

        let results = try context.fetch(request)
        for phrase in results {
            context.delete(phrase)
        }
    }

    private func deleteOrphanedCategories(in context: NSManagedObjectContext, with presets: PresetData) throws {

        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = {
            let presetCategoryIdentifiers = Set(presets.categories.map(\.id))
            let isNotUserGenerated = !Predicate(\Category.isUserGenerated)
            let isNotPresetCategory = !Predicate(\Category.identifier, isContainedIn: presetCategoryIdentifiers)
            return isNotUserGenerated && isNotPresetCategory
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
            let isUserGeneratedCategory = Predicate(\Category.isUserGenerated)
            let isNotUserPrefixed = !Predicate(\Category.identifier, beginsWith: "user_")
            return isUserGeneratedCategory && isNotUserPrefixed
        }()

        let results = try context.fetch(request)
        for category in results {
            context.delete(category)
        }
    }

    private func createPrescribedEntities(in context: NSManagedObjectContext, with presets: PresetData) throws {

        try updateDefaultCategories(in: context, withPresets: presets)
        try updateDefaultPhrases(in: context, withPresets: presets)
    }

    private func updateDefaultCategories(in context: NSManagedObjectContext, withPresets presets: PresetData) throws {
        for presetCategory in presets.categories {
            let category = Category.fetchOrCreate(in: context, matching: presetCategory.id)
            if !category.isUserRenamed {
                category.name = presetCategory.utterance
                category.languageCode = presetCategory.languageCode
            }
            if category.isInserted {
                category.isHidden = presetCategory.hidden
            }
        }
    }

    private func updateDefaultPhrases(in context: NSManagedObjectContext, withPresets presets: PresetData) throws {
        for presetPhrase in presets.phrases {

            let phrase = Phrase.fetchOrCreate(in: context, matching: presetPhrase.id)
            if !phrase.isUserRenamed {
                phrase.utterance = presetPhrase.utterance
                phrase.languageCode = presetPhrase.languageCode
            }
            for identifier in presetPhrase.categoryIds {
                if let category = Category.fetchObject(in: context, matching: identifier) {
                    phrase.category = category
                    category.addToPhrases(phrase)
                }
            }
        }
    }
}
