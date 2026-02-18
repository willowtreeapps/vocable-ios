//
//  AccessibilityID+Shared+Keyboard.swift
//  Vocable
//
//  Created by Rudy Salas on 5/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.shared {
    public struct keyboard {
        public static let outputTextView: AccessibilityID = "keyboard-text-view"
        public static let favoriteButton: AccessibilityID = "favorite-button"
        public static let saveButton: AccessibilityID = "checkmark-save-button"
        public static let view: AccessibilityID = "keyboard-view"

        public static func key(_ action: KeyboardKeyAction) -> AccessibilityID {
            switch action {
            case .insertCharacter(let char):
                AccessibilityID(stringLiteral: "keyboard_function_insert_character_\(char)")
            case .clear:
                AccessibilityID(stringLiteral: "keyboard_function_clear")
            case .backspace:
                AccessibilityID(stringLiteral: "keyboard_function_backspace")
            case .space:
                AccessibilityID(stringLiteral: "keyboard_function_space")
            case .speak:
                AccessibilityID(stringLiteral: "keyboard_function_speak")
            case .numberPad:
                AccessibilityID(stringLiteral: "keyboard_function_navigate_numpad")
            case .alphabet:
                AccessibilityID(stringLiteral: "keyboard_function_navigate_alphabet")
            case .openModifierPicker:
                AccessibilityID(stringLiteral: "keyboard_function_navigate_open_modifiers")
            case .closeModifierPicker:
                AccessibilityID(stringLiteral: "keyboard_function_navigate_close_modifiers")
            case .beginModifier(let mod):
                AccessibilityID(stringLiteral: "keyboard_function_begin_modifier_\(mod)")
            case .endModifier(let mod):
                AccessibilityID(stringLiteral: "keyboard_function_end_modifier_\(mod)")
            case .moveCursorLeft:
                AccessibilityID(stringLiteral: "keyboard_function_move_cursor_left")
            case .moveCursorRight:
                AccessibilityID(stringLiteral: "keyboard_function_move_cursor_right")
            }
        }
        
        private init() {}
    }
}
