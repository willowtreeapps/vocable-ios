//
//  Category+Helpers.swift
//  Vocable
//
//  Created by Thomas Shealy on 4/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import CoreData

extension Category {
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
    
    static func isUserGeneratedCategory(identifier: String, in context: NSManagedObjectContext) -> Bool {
        guard let category = Category.fetchObject(in: context, matching: identifier) else { return false }
        return category.isUserGenerated
    }
}
