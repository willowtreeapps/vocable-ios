//
//  TextPresets.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

enum PresetCategory: CaseIterable, Comparable {
    static func < (lhs: PresetCategory, rhs: PresetCategory) -> Bool {
        lhs.description < rhs.description
    }
    
    case category1
    case category2
    case category3
    case category4
    case category5
    case category6
    
    var description: String {
        switch self {
        case .category1:
            return "Basic Needs"
        case .category2:
            return "Salutations"
        case .category3:
            return "Temperature"
        case .category4:
            return "Body"
        case .category5:
            return "Test category 5"
        case .category6:
            return "Test category 6"
        }
    }
}

struct TextPresets {
    
    static private var presetsByCategory: [PresetCategory: [String]] = [
        .category1: ["I want the door closed.",
                     "I want the door open.",
                     "I would like to go to the bathroom.",
                     "I want the lights off.",
                     "I want the lights on.",
                     "I want my pillow fixed.",
                     "I would like some water.",
                     "I would like some coffee.",
                     "I want another pillow."],
        .category2: ["Hello",
                     "How are you?",
                     "Bye",
                     "Goodbye",
                     "Okay",
                     "How's it going?",
                     "Good",
                     "How is your day?",
                     "Bad"],
        .category3: ["I am cold",
                     "I am hot",
                     "I want more blankets",
                     "I want less blankets",
                     "I feel fine",
                     "I am sweating",
                     "I am freezing",
                     "I need a towel",
                     "I need a jacket"],
        .category4: ["Head",
                     "Feet",
                     "Hands",
                     "Neck",
                     "Arm",
                     "Knee",
                     "Side",
                     "Right",
                     "Left"],
        .category5: ["Test cat 5"],
        .category6: ["Test cat 6"]
    ]
    
    static func presetsForCategories(in range: Range<Int>) -> [PresetCategory: [String]] {
        let allCategories = presetsByCategory.keys.sorted()
        let safeRange = range.clamped(to: (0..<allCategories.count))
        let categoriesInRange = allCategories[range.clamped(to: safeRange)]
        
        return presetsByCategory.filter { categoriesInRange.contains($0.key) }
    }
}
