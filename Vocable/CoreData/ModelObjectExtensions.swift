//
//  ModelObjectExtensions.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/21/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//
import CoreData
import Foundation

extension Category: NSManagedObjectIdentifiable {
    typealias IdentifierType = String

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: #keyPath(creationDate))
        setPrimitiveValue(false, forKey: #keyPath(isUserGenerated))
    }

    static func userFavoritesCategoryName() -> String {
        let context = NSPersistentContainer.shared.viewContext
        guard let favoritesCategory = Category.fetchObject(in: context, matching: TextPresets.userFavoritesCategoryIdentifier) else {
            assertionFailure("debug.assertion.user_favorites_category_not_found")
            return ""
        }
        return favoritesCategory.name ?? ""
    }
}

extension Phrase: NSManagedObjectIdentifiable {
    typealias IdentifierType = String

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: #keyPath(creationDate))
        setPrimitiveValue(false, forKey: #keyPath(isUserGenerated))
    }
}
