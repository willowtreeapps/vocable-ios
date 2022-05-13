//
//  PresetsBuilders.swift
//  VocableUITests
//
//  Created by Chris Stroud on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

struct Phrase {

    let id: String
    let languageCode: String
    let utterance: String

    init(
        id: String = UUID().uuidString,
        languageCode: String = "en",
        _ utterance: String
    ) {
        self.id = id
        self.languageCode = languageCode
        self.utterance = utterance
    }
}

struct Category {

    let presetCategory: PresetCategory
    let presetPhrases: [PresetPhrase]

    init(
        id: String = UUID().uuidString,
        _ name: String,
        hidden: Bool = false,
        languageCode: String = "en",
        @ListBuilder<Phrase> _ phrasesBuilder: () -> [Phrase]
    ) {

        let category = PresetCategory(id: id, hidden: hidden, languageCode: languageCode, utterance: name)
        let phrases = phrasesBuilder().map { phrase in
            PresetPhrase(id: phrase.id, categoryIds: [category.id], languageCode: phrase.languageCode, utterance: phrase.utterance)
        }

        self.presetCategory = category
        self.presetPhrases = phrases
    }
    
    init(
        id: String = UUID().uuidString,
        _ name: String,
        hidden: Bool = false,
        languageCode: String = "en",
        phrases: [Phrase]
    ) {

        let category = PresetCategory(id: id, hidden: hidden, languageCode: languageCode, utterance: name)
        let phrases = phrases.map { phrase in
            PresetPhrase(id: phrase.id, categoryIds: [category.id], languageCode: phrase.languageCode, utterance: phrase.utterance)
        }

        self.presetCategory = category
        self.presetPhrases = phrases
    }
}


struct Presets: LaunchEnvironmentEncodable {

    private let presetData: PresetData

    init(
        schemaVersion: Int = 1,
        @ListBuilder<Category> _ categoriesBuilder: () -> [Category]
    ) {
        let categories = categoriesBuilder()
        self.presetData = .init(schemaVersion: schemaVersion,
                                categories: categories.map(\.presetCategory),
                                phrases: Array(categories.map(\.presetPhrases).joined()))
    }

    func encoded() -> String {
        let data = try! JSONEncoder().encode(self.presetData)
        let stringified = String(data: data, encoding: .utf8)!
        return stringified
    }

    func launchEnvironmentValue() -> String {
        return encoded()
    }
}
