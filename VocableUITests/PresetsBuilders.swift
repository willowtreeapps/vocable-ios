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

    init(id: String = UUID().uuidString, languageCode: String = "en", _ utterance: String) {
        self.id = id
        self.languageCode = languageCode
        self.utterance = utterance
    }
}

struct Category {

    @resultBuilder
    enum PhraseBuilder {
        static func buildBlock(_ components: Phrase...) -> [Phrase] {
            components
        }
    }

    let presetCategory: PresetCategory
    let presetPhrases: [PresetPhrase]

    init(_ name: String, hidden: Bool = false, languageCode: String = "en", @PhraseBuilder _ phrasesBuilder: () -> [Phrase]) {

        let category = PresetCategory(id: UUID().uuidString, hidden: hidden, languageCode: languageCode, utterance: name)
        let phrases = phrasesBuilder().map { phrase in
            PresetPhrase(id: phrase.id, categoryIds: [category.id], languageCode: phrase.languageCode, utterance: phrase.utterance)
        }

        self.presetCategory = category
        self.presetPhrases = phrases
    }
}


struct Presets {

    @resultBuilder
    enum CategoryBuilder {
        static func buildBlock(_ components: Category...) -> [Category] {
            components
        }
    }

    private let presetData: PresetData

    init(schemaVersion: Int = 1, @CategoryBuilder _ categoriesBuilder: () -> [Category]) {
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

    func encoded(to app: XCUIApplication, environmentKey: LaunchEnvironment.Key = .overriddenPresets) {
        app.launchEnvironment[environmentKey.rawValue] = self.encoded()
    }
}
