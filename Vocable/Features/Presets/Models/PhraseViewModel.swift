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
        return _languageCode ?? AppConfig.activePreferredLanguageCode
    }
    let creationDate: Date
    let category: CategoryViewModel?
    
    init(unpersistedPhrase phrase: String) {
        self.utterance = phrase
        self._languageCode = nil
        self.identifier = UUID().uuidString
        self.creationDate = Date()
        self.category = nil
    }
    
    init?(_ phrase: Phrase?) {

        guard let phrase = phrase,
            let identifier = phrase.identifier,
            let utterance = phrase.utterance,
            let creationDate = phrase.creationDate,
            let category = phrase.category else {
                return nil
        }
        self._languageCode = phrase.languageCode
        self.identifier = identifier
        self.utterance = utterance
        self.creationDate = creationDate
        self.category = CategoryViewModel(category)
    }

    private var _languageCode: String?

}
