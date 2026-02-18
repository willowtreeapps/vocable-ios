//
//  KeyboardKeyAction.swift
//  Vocable
//
//  Created by Chris Stroud on 8/2/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

public enum KeyboardKeyAction: Hashable {
    case clear
    case backspace
    case space
    case speak
    case numberPad
    case alphabet
    case openModifierPicker
    case closeModifierPicker
    case beginModifier(Character)
    case endModifier(Character)
    case insertCharacter(Character)
    case moveCursorLeft
    case moveCursorRight

    var isStandardKey: Bool {
        if case .insertCharacter = self {
            return true
        }
        return false
    }
}
