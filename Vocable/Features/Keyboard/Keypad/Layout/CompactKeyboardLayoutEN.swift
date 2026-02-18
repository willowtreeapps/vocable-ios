//
//  CompactKeyboardLayoutEN.swift
//  Vocable
//
//  Created by Chris Stroud on 6/12/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import SwiftUI
import Collections

struct CompactKeyboardLayoutEN: KeyboardLayout {

    let identifier = "compact_layout_EN"

    func makeLayout(
        configuration: KeyboardLayoutConfiguration
    ) -> KeyboardBody {
        switch configuration.mode {
        case .alphabetical:
            let values = "ABCDEFGHIJKLMNOPQRSTUVWXYZ',.?"
            KeyboardLayoutGroup {
                for row in values.chunks(ofCount: 6) {
                    KeyboardLayoutRow {
                        for key in row {
                            KeyboardLayoutKey(key)
                        }
                    }
                }
                KeyboardLayoutRow {
                    for key in "()!\"" {
                        KeyboardLayoutKey(key)
                    }
                    KeyboardLayoutKey(.backspace)
                        .keyWidth(span: 2)
                }
            }
            .keyWidth(count: 6)
        case .numerical:
            let values = "123456789"
            for row in values.chunks(ofCount: 3) {
                KeyboardLayoutRow {
                    for key in row {
                        KeyboardLayoutKey(key)
                            .keyWidth(count: 3)
                    }
                }
            }
            KeyboardLayoutRow {
                KeyboardLayoutKey(".")
                KeyboardLayoutKey("0")
                KeyboardLayoutKey(.backspace)
            }
            .keyWidth(count: 3)
        case .modifierPicker:
            KeyboardLayoutGroup { }
        }
        KeyboardLayoutRow {
            KeyboardLayoutKey(
                configuration.mode == .alphabetical ? .numberPad : .alphabet
            )
            .keyWidth(span: 3)
            KeyboardLayoutKey(.moveCursorLeft)
                .keyWidth(span: 2)
            KeyboardLayoutKey(.space)
                .keyWidth(span: 4)
            KeyboardLayoutKey(.moveCursorRight)
                .keyWidth(span: 2)
            KeyboardLayoutKey(.speak)
                .keyWidth(span: 3)
        }
        .keyWidth(count: 12)
    }
}

#Preview {
    KeyboardLayoutPreviewView(
        layout: CompactKeyboardLayoutEN(),
        mode: .alphabetical
    )
}
