//
//  TextPresets.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct PresetCategory: Codable {
    var title: String
    var presets: [String]
}

struct TextPresets {
    static let savedSayingsIdentifier = NSLocalizedString("My Sayings", comment: "Category: My Sayings")

    static let numPadDescription = NSLocalizedString("123 | Yes | No", comment: "Category: 123 | Yes | No")

    static var numPadCategory: [PhraseViewModel] {
        var numbers = (1...9).map { PhraseViewModel(unpersistedPhrase: "\($0)")}
        numbers.append(PhraseViewModel(unpersistedPhrase: "0"))
        let responses = [PhraseViewModel(unpersistedPhrase: NSLocalizedString("No", comment: "'No' num pad response")),
                         PhraseViewModel(unpersistedPhrase: NSLocalizedString("Yes", comment: "'Yes' num pad response"))]
        return numbers + responses
    }

    static var presetsByCategory: [PresetCategory] {
        var result: [PresetCategory] = []

        if let path = Bundle.main.path(forResource: "textpresets", ofType: "json") {
            do {
                let json = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

                let categories = try! JSONDecoder().decode([PresetCategory].self, from: json)

                result = categories
            } catch {
                print("🚨 Cannot parse \(path)")
            }
        }

        result.append(PresetCategory(title: TextPresets.savedSayingsIdentifier, presets: []))
        result.append(PresetCategory(title: TextPresets.numPadDescription, presets: []))

        return result
    }
}
