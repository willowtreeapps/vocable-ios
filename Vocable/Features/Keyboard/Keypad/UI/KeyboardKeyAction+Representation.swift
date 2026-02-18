//
//  KeyboardKeyAction.swift
//  Vocable
//
//  Created by Chris Stroud on 7/31/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension KeyboardKeyAction {

    enum Representation: Hashable {
        case image(UIImage)
        case string(String)
    }

    var representation: Representation {
        return switch self {
        case .insertCharacter(let value):
            .string(String(value))
        case .clear:
            .image(UIImage(systemName: "trash")!)
        case .backspace:
            .image(UIImage(systemName: "delete.left")!)
        case .space:
            .image(UIImage(systemName: "space")!)
        case .speak:
            .image(UIImage(systemName: "person.wave.2.fill")!)
        case .numberPad:
            .image(UIImage(systemName: "textformat.123")!)
        case .alphabet:
            .image(UIImage(systemName: "abc")!)
        case .openModifierPicker, .closeModifierPicker:
            .image(UIImage(systemName: "ellipsis")!)
        case .beginModifier(let value), .endModifier(let value):
            .string("\u{25CC}\(value)")
        case .moveCursorLeft:
            .image(UIImage(systemName: "arrow.left")!)
        case .moveCursorRight:
            .image(UIImage(systemName: "arrow.right")!)
        }
    }
}
