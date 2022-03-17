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

            // Need to merge latest from develop

//            try createPrescribedEntities(in: context, with: presets)
//            try deleteOrphanedPhrases(in: context, with: presets)
//            try deleteOrphanedCategories(in: context, with: presets)
//            try deleteLegacyUserFavoritesCategoryIfNeeded(in: context)
//            try Category.updateAllOrdinalValues(in: context)

            try context.save()
        } catch {
            assertionFailure(error.localizedDescription)
            return false
        }

        return true
    }
}
