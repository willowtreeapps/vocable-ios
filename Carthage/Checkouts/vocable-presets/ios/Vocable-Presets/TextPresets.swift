//
//  TextPresets.swift
//  Vocable-Presets
//
//  Created by Steve Foster on 4/13/20.
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
