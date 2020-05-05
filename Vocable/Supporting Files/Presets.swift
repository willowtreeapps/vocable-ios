//
//  Presets.swift
//  Vocable
//
//  Created by Barry Bryant on 5/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

// Top level JSON object
public struct PresetData: Codable {

    public let schemaVersion: Int
    public let categories: [PresetCategory]
    public let phrases: [PresetPhrase]

}

public struct PresetCategory: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case hidden
    }

    public let id: String
    public let hidden: Bool
    public var languageCode: String = ""
    public var utterance: String = ""
}

public struct PresetPhrase: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case categoryIds
    }

    public let id: String
    public let categoryIds: [String]
    public var languageCode: String = ""
    public var utterance: String = ""

}

public struct TextPresets {

    public static var presets: PresetData? {
        if let json = dataFromBundle() {
            do {

                let json = try JSONDecoder().decode(PresetData.self, from: json)

                let localization = Bundle.main.preferredLocalizations.first ?? "en"
                let transformedCategories = json.categories.map { category -> PresetCategory in
                    var preset = PresetCategory(id: category.id, hidden: category.hidden)
                    preset.languageCode = localization
                    preset.utterance = localizedPreset(localization, preset.id)
                    return preset
                }

                let transformedPhrases = json.phrases.map { phrase -> PresetPhrase in
                    var preset = PresetPhrase(id: phrase.id, categoryIds: phrase.categoryIds)
                    preset.languageCode = localization
                    preset.utterance = localizedPreset(localization, phrase.id)
                    return preset
                }
                let result = PresetData(schemaVersion: json.schemaVersion,
                                        categories: transformedCategories,
                                        phrases: transformedPhrases)
                return result
            } catch {
                assertionFailure("Error decoding PresetData: \(error)")
            }
        }

        return nil
    }
    
    static func localizedPreset(_ locale: String, _ key: String, comment: String? = nil) -> String {
        guard let path = Bundle.main.path(forResource: locale, ofType: "lproj"), let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: comment ?? "")
        }
        return NSLocalizedString(key, tableName: "Presets", bundle: bundle, value: key, comment: "")
    }

    private static func dataFromBundle() -> Data? {

        if let path = Bundle.main.path(forResource: "presets", ofType: "json") {
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
