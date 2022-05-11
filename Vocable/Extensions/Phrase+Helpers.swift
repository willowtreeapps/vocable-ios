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

    var isAnalyticsReportable: Bool {
        !isUserRenamed && !isUserGenerated
    }

    static func create(withUserEntry text: String, in context: NSManagedObjectContext) throws -> Phrase {
        let userFavorites = try Category.fetch(.userFavorites, in: context)
        return create(withUserEntry: text, category: userFavorites, in: context)
    }

    static func create(withUserEntry text: String, category: Category, in context: NSManagedObjectContext) -> Phrase {
        let newIdentifier = "user_\(UUID().uuidString)"
        let phrase = Phrase.fetchOrCreate(in: context, matching: newIdentifier)
        phrase.isUserGenerated = true
        phrase.creationDate = Date()
        phrase.utterance = text
        phrase.languageCode = AppConfig.activePreferredLanguageCode
        phrase.category = category
        category.addToPhrases(phrase)
        return phrase
    }

}
