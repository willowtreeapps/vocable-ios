//
//  KeyboardPresets.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct KeyboardPresets {

    static let userFavoritesCategoryIdentifier = "preset_user_favorites"
    static let numPadIdentifier = "preset_user_keypad"
    
    private static let numpadKeyFormatter = NumberFormatter()

    static var numPadPhrases: [PhraseViewModel] {
        let phraseNoTitle = NSLocalizedString("preset.category.numberpad.phrase.no.title",
                                              comment: "'No' num pad response")
        let phraseYesTitle = NSLocalizedString("preset.category.numberpad.phrase.yes.title",
                                               comment: "'Yes' num pad response")

        // For this keypad layout, the 0 comes after the rest of the numbers
        let numbers = (Array(1...9) + [0]).map { intValue -> PhraseViewModel in
            let value = NSNumber(integerLiteral: intValue)
            let formatted = KeyboardPresets.numpadKeyFormatter.string(from: value)
            return PhraseViewModel(unpersistedPhrase: formatted!)
        }
        let responses = [PhraseViewModel(unpersistedPhrase: phraseNoTitle),
                         PhraseViewModel(unpersistedPhrase: phraseYesTitle)]
        return numbers + responses
    }

}
