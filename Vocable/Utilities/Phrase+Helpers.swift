//
//  Phrase+Helpers.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import CoreData

extension Phrase {

    //TODO: This should be removed after refactoring PresetsViewController et al
    static func create(withUserEntry text: String, in context: NSManagedObjectContext) -> Phrase {
        let newIdentifier = "user_\(UUID().uuidString)"
        let savedCategory = Category.fetch(.userFavorites, in: context)
        let phrase = Phrase.fetchOrCreate(in: context, matching: newIdentifier)
        phrase.isUserGenerated = true
        phrase.creationDate = Date()
        phrase.lastSpokenDate = Date()
        phrase.utterance = text
        phrase.languageCode = AppConfig.activePreferredLanguageCode
        phrase.addToCategories(savedCategory)
        savedCategory.addToPhrases(phrase)
        return phrase
    }

    static func create(withUserEntry text: String, category: Category, in context: NSManagedObjectContext) -> Phrase {
        let newIdentifier = "user_\(UUID().uuidString)"
        let phrase = Phrase.fetchOrCreate(in: context, matching: newIdentifier)
        phrase.isUserGenerated = true
        phrase.creationDate = Date()
        phrase.lastSpokenDate = Date()
        phrase.utterance = text
        phrase.languageCode = AppConfig.activePreferredLanguageCode
        phrase.addToCategories(category)
        category.addToPhrases(phrase)
        return phrase
    }

}
