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
        
        //let newIdentifier = text
        let category = Category.fetchOrCreate(in: context, matching: text)
        category.isUserGenerated = true
        category.languageCode = AppConfig.activePreferredLanguageCode
        category.name = text
        category.identifier = text
        return category
    }
}
