//
//  TextPresets.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

enum PresetCategory: CaseIterable {
    case category1
    case category2
    case category3
    case category4
    case category5
    case saved
    
    var description: String {
        switch self {
        case .category1:
            return NSLocalizedString("General", comment: "Category: General")
        case .category2:
            return NSLocalizedString("Basic Needs", comment: "Category: Basic Needs")
        case .category3:
            return NSLocalizedString("Personal Care", comment: "Category: Personal Care")
        case .category4:
            return NSLocalizedString("Conversation", comment: "Category: Conversation")
        case .category5:
            return NSLocalizedString("Environment", comment: "Category: Environment")
        case .saved:
            return NSLocalizedString("My Sayings", comment: "Category: My Sayings")
        }
    }
}

struct TextPresets {
    
    static var presetsByCategory: [PresetCategory: [String]] = [
        .category1: [NSLocalizedString("Please", comment: "Preset: Please"),
                     NSLocalizedString("Thank you", comment: "Preset: Thank you"),
                     NSLocalizedString("Yes", comment: "Preset: Yes"),
                     NSLocalizedString("No", comment: "Preset: No"),
                     NSLocalizedString("Maybe", comment: "Preset: Maybe"),
                     NSLocalizedString("Please wait", comment: "Preset: Please wait"),
                     NSLocalizedString("I don't know", comment: "Preset: I don't know"),
                     NSLocalizedString("I didn't mean to say that", comment: "Preset: I didn't mean to say that"),
                     NSLocalizedString("Please be patient", comment: "Preset: Please be patient")],
        .category2: [NSLocalizedString("I need to go to the restroom", comment: "Preset: I need to go to the restroom"),
                     NSLocalizedString("I am thirsty", comment: "Preset: I am thirsty"),
                     NSLocalizedString("I am hungry", comment: "Preset: I am hungry"),
                     NSLocalizedString("I am cold", comment: "Preset: I am cold"),
                     NSLocalizedString("I am hot", comment: "Preset: I am hot"),
                     NSLocalizedString("I am tired", comment: "Preset: I am tired"),
                     NSLocalizedString("I am fine", comment: "Preset: I am fine"),
                     NSLocalizedString("I am good", comment: "Preset: I am good"),
                     NSLocalizedString("I am uncomfortable", comment: "Preset: I am uncomfortable"),
                     NSLocalizedString("I am in pain", comment: "Preset: I am in pain"),
                     NSLocalizedString("I am finished", comment: "Preset: I am finished"),
                     NSLocalizedString("I want to lie down", comment: "Preset: I want to lie down"),
                     NSLocalizedString("I want to sit up", comment: "Preset: I want to sit up")],
        .category3: [NSLocalizedString("I need my medication", comment: "Preset: I need my medication"),
                     NSLocalizedString("I need a bath", comment: "Preset: I need a bath"),
                     NSLocalizedString("I need a shower", comment: "Preset: I need a shower"),
                     NSLocalizedString("I need to wash my face", comment: "Preset: I need to wash my face"),
                     NSLocalizedString("I need to brush my hair", comment: "Preset: I need to brush my hair"),
                     NSLocalizedString("Please fix my pillow", comment: "Preset: Please fix my pillow"),
                     NSLocalizedString("I need to spit", comment: "Preset: I need to spit"),
                     NSLocalizedString("I am having trouble breathing", comment: "Preset: I am having trouble breathing"),
                     NSLocalizedString("I need a jacket", comment: "Preset: I need a jacket")],
        .category4: [NSLocalizedString("Hello", comment: "Preset: Hello"),
                     NSLocalizedString("Good morning", comment: "Preset: Good morning"),
                     NSLocalizedString("Good evening", comment: "Preset: Good evening"),
                     NSLocalizedString("Pleased to meet you", comment: "Preset: Pleased to meet you"),
                     NSLocalizedString("How is your day?", comment: "Preset: How is your day?"),
                     NSLocalizedString("How are you?", comment: "Preset: How are you?"),
                     NSLocalizedString("How's it going?", comment: "Preset: How's it going?"),
                     NSLocalizedString("How was your weekend?", comment: "Preset: How was your weekend?"),
                     NSLocalizedString("Goodbye", comment: "Preset: Goodbye"),
                     NSLocalizedString("Okay", comment: "Preset: Okay"),
                     NSLocalizedString("Bad", comment: "Preset: Bad"),
                     NSLocalizedString("Good", comment: "Preset: Good"),
                     NSLocalizedString("That makes sense", comment: "Preset: That makes sense"),
                     NSLocalizedString("I like it", comment: "Preset: I like it"),
                     NSLocalizedString("Please stop", comment: "Preset: Please stop"),
                     NSLocalizedString("I do not agree", comment: "Preset: I do not agree"),
                     NSLocalizedString("Please repeat what you said", comment: "Preset: Please repeat what you said")],
        .category5: [NSLocalizedString("Please turn the lights on", comment: "Preset: Please turn the lights on"),
                     NSLocalizedString("Please turn the lights off", comment: "Preset: Please turn the lights off"),
                     NSLocalizedString("No visitors please", comment: "Preset: No visitors please"),
                     NSLocalizedString("I would like visitors", comment: "Preset: I would like visitors"),
                     NSLocalizedString("Please be quiet", comment: "Preset: Please be quiet"),
                     NSLocalizedString("I would like to talk", comment: "Preset: I would like to talk"),
                     NSLocalizedString("Please turn the TV on", comment: "Preset: Please turn the TV on"),
                     NSLocalizedString("Please turn the TV off", comment: "Preset: Please turn the TV off"),
                     NSLocalizedString("Please turn the volume up", comment: "Preset: Please turn the volume up"),
                     NSLocalizedString("Please turn the volume down", comment: "Preset: Please turn the volume down"),
                     NSLocalizedString("Please open the blinds", comment: "Preset: Please open the blinds"),
                     NSLocalizedString("Please close the blinds", comment: "Preset: Please close the blinds"),
                     NSLocalizedString("Please open the window", comment: "Preset: Please open the window"),
                     NSLocalizedString("Please close the window", comment: "Preset: Please close the window")]
                     
    ]
}
