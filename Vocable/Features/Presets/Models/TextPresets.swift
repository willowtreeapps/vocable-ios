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

        return result
    }
}
