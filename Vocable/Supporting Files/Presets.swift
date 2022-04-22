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
        case languageCode
        case utterance
    }

    public let id: String
    public let hidden: Bool
    public var languageCode: String = ""
    public var utterance: String = ""

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.hidden = try container.decode(Bool.self, forKey: .hidden)
        if let utterance = try? container.decode(String.self, forKey: .utterance) {
            self.utterance = utterance
        }
        if let languageCode = try? container.decode(String.self, forKey: .languageCode) {
            self.languageCode = languageCode
        }
    }

    init(id: String, hidden: Bool, languageCode: String? = nil, utterance: String? = nil) {
        self.id = id
        self.hidden = hidden
        if let languageCode = languageCode {
            self.languageCode = languageCode
        }
        if let utterance = utterance {
            self.utterance = utterance
        }
    }
}

public struct PresetPhrase: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case categoryIds
        case languageCode
        case utterance
    }

    public let id: String
    public let categoryIds: [String]
    public var languageCode: String = ""
    public var utterance: String = ""

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.categoryIds = try container.decode([String].self, forKey: .categoryIds)
        if let utterance = try? container.decode(String.self, forKey: .utterance) {
            self.utterance = utterance
        }
        if let languageCode = try? container.decode(String.self, forKey: .languageCode) {
            self.languageCode = languageCode
        }
    }

    init(id: String, categoryIds: [String], languageCode: String? = nil, utterance: String? = nil) {
        self.id = id
        self.categoryIds = categoryIds
        if let languageCode = languageCode {
            self.languageCode = languageCode
        }
        if let utterance = utterance {
            self.utterance = utterance
        }
    }
}

public struct TextPresets {

    private static var _cachedOverride: PresetData?

    private static var overriddenPresets: PresetData? {
        guard let overrideString = ProcessInfo.processInfo.environment["OverridePresets"] else {
            return nil
        }
        if let cached = _cachedOverride {
            return cached
        }
        if let data = overrideString.data(using: .utf8) {
            if let decoded = try? JSONDecoder().decode(PresetData.self, from: data) {
                _cachedOverride = decoded
                return decoded
            }
        }
        return nil
    }

    public static var presets: PresetData? {

        if let overriddenPresets = overriddenPresets {
            return overriddenPresets
        }

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
            return NSLocalizedString(key, tableName: "Presets", comment: "")
        }
        return NSLocalizedString(key, tableName: "Presets", bundle: bundle, comment: "")
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
