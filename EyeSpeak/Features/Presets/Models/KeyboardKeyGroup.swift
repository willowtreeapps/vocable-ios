//
//  KeyboardKeyGroup.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct KeyGroup: Hashable {
    static let QWERTYKeyboardGroups = [
        KeyGroup("QWE"),
        KeyGroup("RTY"),
        KeyGroup("UIOP"),
        KeyGroup("ASD"),
        KeyGroup("FGH"),
        KeyGroup("JKL"),
        KeyGroup("ZXC"),
        KeyGroup("VBNM")
    ]
    
    let containedCharacters: String
    
    init(_ containedCharacters: String) {
        self.containedCharacters = containedCharacters
    }
}
