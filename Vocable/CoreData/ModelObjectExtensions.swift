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
        setPrimitiveValue(Int32.max, forKey: #keyPath(ordinal))
    }

    static func userFavoritesCategoryName() -> String {
        let context = NSPersistentContainer.shared.viewContext
        let category = Category.fetch(.userFavorites, in: context)
        return category.name ?? ""
    }

    static func userFavoritesCategory() -> Category {
        let context = NSPersistentContainer.shared.viewContext
        let category = Category.fetch(.userFavorites, in: context)
        return category
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
