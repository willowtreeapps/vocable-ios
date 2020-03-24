//
//  TextPresets.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

enum PresetCategory: CaseIterable {
    case numPad
    case category1
    case category2
    case category3
    case category4
    case category5
    case saved
    
    var description: String {
        switch self {
        case .numPad:
            return "123 | Yes | No"
        case .category1:
            return "General"
        case .category2:
            return "Basic Needs"
        case .category3:
            return "Personal Care"
        case .category4:
            return "Conversation"
        case .category5:
            return "Environment"
        case .saved:
            return "My Sayings"
        }
    }
}

struct TextPresets {
    
    static var numPadCategory: [PhraseViewModel] {
        var numbers = (1...9).map { PhraseViewModel(unpersistedPhrase: "\($0)")}
        numbers.append(PhraseViewModel(unpersistedPhrase: "0"))
        let responses = [PhraseViewModel(unpersistedPhrase: NSLocalizedString("No", comment: "'No' num pad response")),
                         PhraseViewModel(unpersistedPhrase: NSLocalizedString("Yes", comment: "'Yes' num pad response"))]
        return numbers + responses
    }
    
    static var presetsByCategory: [PresetCategory: [String]] = [
        .category1: ["Please",
                     "Thank you",
                     "Yes",
                     "No",
                     "Maybe",
                     "Please wait",
                     "I don't know",
                     "I didn't mean to say that",
                     "Please be patient"],
        .category2: ["I need to go to the restroom",
                     "I am thirsty",
                     "I am hungry",
                     "I am cold",
                     "I am hot",
                     "I am tired",
                     "I am fine",
                     "I am good",
                     "I am uncomfortable",
                     "I am in pain",
                     "I am finished",
                     "I want to lie down",
                     "I want to sit up"],
        .category3: ["I need my medication",
                     "I need a bath",
                     "I need a shower",
                     "I need to wash my face",
                     "I need to brush my hair",
                     "Please fix my pillow",
                     "I need to spit",
                     "I am having trouble breathing",
                     "I need a jacket"],
        .category4: ["Hello",
                     "Good morning",
                     "Good evening",
                     "Pleased to meet you",
                     "How is your day?",
                     "How are you?",
                     "How's it going?",
                     "How was your weekend?",
                     "Goodbye",
                     "Okay",
                     "Bad",
                     "Good",
                     "That makes sense",
                     "I like it",
                     "Please stop",
                     "I do not agree",
                     "Please repeat what you said"],
        .category5: ["Please turn the lights on",
                     "Please turn the lights off",
                     "No visitors please",
                     "I would like visitors",
                     "Please be quiet",
                     "I would like to talk",
                     "Please turn the TV on",
                     "Please turn the TV off",
                     "Please turn the volume up",
                     "Please turn the volume down",
                     "Please open the blinds",
                     "Please close the blinds",
                     "Please open the window",
                     "Please close the window"]
                     
    ]
}
