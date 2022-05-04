//
//  Category+Helpers.swift
//  Vocable
//
//  Created by Thomas Shealy on 4/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import CoreData
import Algorithms

extension Category {

    enum FetchError: Error {
        case presetCategoryNotFound(String)
    }

    // Category identifiers that are reserved for special
    // cases and *must* match the preset dataset
    enum Identifier: String {
        
        case userFavorites = "preset_user_favorites"
        case numPad = "preset_user_keypad"
        case recents = "preset_user_recents"
        case listeningMode = "preset_listening_mode"

        static func == (lhs: String?, rhs: Identifier) -> Bool {
            guard let lhs = lhs else { return false }
            return rhs.rawValue == lhs
        }

        static func == (lhs: Identifier, rhs: String?) -> Bool {
            guard let rhs = rhs else { return false }
            return lhs.rawValue == rhs
        }

        static func != (lhs: Identifier, rhs: String?) -> Bool {
            guard let rhs = rhs else { return true }
            return lhs.rawValue != rhs
        }

        static func != (lhs: String?, rhs: Identifier) -> Bool {
            guard let lhs = lhs else { return true }
            return rhs.rawValue != lhs
        }

        fileprivate var allowsCustomPhrases: Bool {
            switch self {
            case .userFavorites:
                return true
            case .numPad, .recents, .listeningMode:
                return false
            }
        }
    }

    var allowsCustomPhrases: Bool {
        guard let categoryID = self.identifier else {
            assertionFailure("No identifier present")
            return false
        }
        if let specialIdentifier = Identifier(rawValue: categoryID) {
            return specialIdentifier.allowsCustomPhrases
        }
        return true
    }

    static func fetch(_ identifier: Identifier, in context: NSManagedObjectContext) throws -> Category {
        guard let category = Category.fetchObject(in: context, matching: identifier.rawValue) else {
            throw FetchError.presetCategoryNotFound(identifier.rawValue)
        }
        return category
    }

    static func create(withUserEntry text: String, in context: NSManagedObjectContext) -> Category {
        let newIdentifier = "user_\(UUID().uuidString)"
        let category = Category.fetchOrCreate(in: context, matching: text)
        category.isUserGenerated = true
        category.creationDate = Date()
        category.languageCode = AppConfig.activePreferredLanguageCode
        category.name = text
        category.identifier = newIdentifier
        return category
    }

    static func visibleCategoriesPredicate(includeUserHidden: Bool = true) -> NSPredicate {
        var predicate = !Predicate(\Category.isUserRemoved)
        if !includeUserHidden {
            predicate &= !Predicate(\Category.isHidden)
        }
        if !AppConfig.listeningMode.isEnabled {
            predicate &= !Predicate(\Category.identifier, equalTo: Category.Identifier.listeningMode)
        }
        return predicate
    }
    
    static func updateAllOrdinalValues(in context: NSManagedObjectContext) throws {

        if let listeningModeCategory = try? Category.fetch(.listeningMode, in: context) {
            listeningModeCategory.isHidden = !AppConfig.listeningMode.isEnabled
        }
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = visibleCategoriesPredicate()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.ordinal, ascending: true),
            NSSortDescriptor(keyPath: \Category.creationDate, ascending: true)
        ]
        let results = try context.fetch(request)
        for (index, category) in results.enumerated() {
            category.ordinal = Int32(index)
            category.canMoveToLowerOrdinal = false
            category.canMoveToHigherOrdinal = false
        }

        try updateOrdinalReorderability(in: context)
    }

    private static func updateOrdinalReorderability(in context: NSManagedObjectContext) throws {

        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = !Predicate(\Category.isUserRemoved) && !Predicate(\Category.isHidden)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.ordinal, ascending: true),
            NSSortDescriptor(keyPath: \Category.creationDate, ascending: true)
        ]
        let results = try context.fetch(request)

        let orderabilityModel = CategoryOrderabilityModel(categories: results)

        for (index, category) in results.indexed() {
            category.canMoveToHigherOrdinal = orderabilityModel.canMoveToHigherIndex(from: index)
            category.canMoveToLowerOrdinal = orderabilityModel.canMoveToLowerIndex(from: index)
        }
    }
}
