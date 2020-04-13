//
//  TextPresets.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

// Top level JSON object
struct PresetData: Codable {

    let schemaVersion: Int
    let categories: [PresetCategory]
    let phrases: [PresetPhrase]

}

struct PresetCategory: Codable {

    let id: String
    let localizedName: [String: String]
    let hidden: Bool

}

struct PresetPhrase: Codable {

    let id: String
    let categoryIds: [String]
    let localizedUtterance: [String: String]

}

struct TextPresets {

    static let userFavoritesCategoryIdentifier = "preset_user_favorites"
    static let numPadIdentifier = "preset_user_keypad"
    
    private static let numpadKeyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()

    static var numPadPhrases: [PhraseViewModel] {
        let phraseNoTitle = NSLocalizedString("preset.category.numberpad.phrase.no.title",
                                              comment: "'No' num pad response")
        let phraseYesTitle = NSLocalizedString("preset.category.numberpad.phrase.yes.title",
                                               comment: "'Yes' num pad response")

        // For this keypad layout, the 0 comes after the rest of the numbers
        let numbers = (Array(1...9) + [0]).map { intValue -> PhraseViewModel in
            let value = NSNumber(integerLiteral: intValue)
            let formatted = TextPresets.numpadKeyFormatter.string(from: value)
            return PhraseViewModel(unpersistedPhrase: formatted!)
        }
        let responses = [PhraseViewModel(unpersistedPhrase: phraseNoTitle),
                         PhraseViewModel(unpersistedPhrase: phraseYesTitle)]
        return numbers + responses
    }

    static var presets: PresetData? {
        if let json = dataFromBundle() {
            do {
                return try JSONDecoder().decode(PresetData.self, from: json)
            } catch {
                assertionFailure("Error decoding PresetData: \(error)")
            }
        }

        return nil
    }

    private static func dataFromBundle() -> Data? {
        if let path = Bundle.main.path(forResource: "textpresets", ofType: "json") {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            } catch {
                assertionFailure("🚨 Cannot parse \(path)")
                return nil
            }
        }

        return nil
    }

}
