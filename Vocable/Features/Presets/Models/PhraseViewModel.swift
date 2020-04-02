//
//  PhraseViewModel.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct PhraseViewModel: Hashable {

    let identifier: String
    let utterance: String
    var languageCode: String {
        return _languageCode ?? Locale.preferredLanguages.first ?? "en"
    }
    let creationDate: Date
    let categories: [CategoryViewModel]
    
    init(unpersistedPhrase phrase: String) {
        self.utterance = phrase
        self._languageCode = nil
        self.identifier = UUID().uuidString
        self.creationDate = Date()
        self.categories = []
    }
    
    init?(_ phrase: Phrase?) {

        guard let phrase = phrase,
            let identifier = phrase.identifier,
            let utterance = phrase.utterance,
            let creationDate = phrase.creationDate,
            let categories = phrase.categories else {
                return nil
        }
        self._languageCode = phrase.languageCode
        self.identifier = identifier
        self.utterance = utterance
        self.creationDate = creationDate
        self.categories = categories.compactMap { CategoryViewModel($0 as? Category) }
    }

    private var _languageCode: String?

}
