//
//  StandardKeyboardLayoutDE.swift
//  Vocable
//
//  Created by Chris Stroud on 6/3/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct StandardKeyboardLayoutDE: KeyboardLayout {

    let identifier = "standard_layout_DE"

    func makeLayout(
        configuration: KeyboardLayoutConfiguration
    ) -> KeyboardBody {
        switch configuration.mode {
        case .alphabetical:
            KeyboardLayoutRow {
                for key in "QWERTYUIOPÅ" {
                    KeyboardLayoutKey(key)
                        .keyWidth(count: 11)
                }
            }
            KeyboardLayoutRow {
                for key in "ASDFGHJKLÆØ" {
                    KeyboardLayoutKey(key)
                        .keyWidth(count: 11)
                }
            }
            KeyboardLayoutRow {
                KeyboardLayoutGroup {
                    for key in "ZXCVBNM" {
                        KeyboardLayoutKey(key)
                            .keyWidth(count: 11)
                    }
                }
                backspaceButton
                    .padding(
                        leading: .columns(100, span: 6)
                    )
            }
            .padding(
                leading: .columns(100, span: 19)
            )
        case .modifierPicker:
            KeyboardLayoutRow {
                KeyboardLayoutKey(.beginModifier("\u{0300}"))
                KeyboardLayoutKey(.beginModifier("\u{0301}"))
                KeyboardLayoutKey(.beginModifier("\u{0302}"))
                KeyboardLayoutKey(.beginModifier("\u{0303}"))
                KeyboardLayoutKey(.beginModifier("\u{0306}"))
                KeyboardLayoutKey(.beginModifier("\u{0307}"))
            }
            .keyWidth(count: 6)
            KeyboardLayoutRow {
                KeyboardLayoutKey(.beginModifier("\u{0308}"))
                KeyboardLayoutKey(.beginModifier("\u{0309}"))
                KeyboardLayoutKey(.beginModifier("\u{030A}"))
                KeyboardLayoutKey(.beginModifier("\u{030B}"))
                KeyboardLayoutKey(.beginModifier("\u{0311}"))
                KeyboardLayoutKey(.beginModifier("\u{0313}"))
            }
            .keyWidth(count: 6)
            KeyboardLayoutRow {
                KeyboardLayoutKey(
                    leadingFunctionKeyFunction(configuration: configuration)
                )
                .padding(
                    trailing: .columns(50, span: 6, spacing: 6.0)
                )
                backspaceButton
                    .padding(
                        leading: .columns(50, span: 28, spacing: 6.0)
                    )
            }
            .keyWidth(count: 50, span: 6)
        case .numerical:
            KeyboardLayoutRow {
                for key in "1234567890" {
                    KeyboardLayoutKey(key)
                }
            }
            .keyWidth(count: 10)
            KeyboardLayoutRow {
                for key in "-/:;()$&@\"" {
                    KeyboardLayoutKey(key)
                }
            }
            .keyWidth(count: 10)
            KeyboardLayoutRow {
                for key in ".,?!'" {
                    KeyboardLayoutKey(key)
                        .keyWidth(count: 100, span: 14)
                }
                backspaceButton
                    .padding(
                        leading: .columns(40, span: 1)
                    )
            }
            .padding(
                leading: .columns(100, span: 16)
            )
        }

        KeyboardLayoutRow {
            KeyboardLayoutKey(configuration.mode == .alphabetical ? .numberPad : .alphabet)
                .keyWidth(span: 10)
            KeyboardLayoutKey(.moveCursorLeft)
                .keyWidth(span: 4)
            KeyboardLayoutKey(.space)
                .keyWidth(span: 12)
            KeyboardLayoutKey(.moveCursorRight)
                .keyWidth(span: 4)
            KeyboardLayoutKey(.speak)
                .keyWidth(span: 10)
        }
        .keyWidth(count: 40)
    }

    private func leadingFunctionKeyFunction(
        configuration: KeyboardLayoutConfiguration
    ) -> KeyboardKeyAction {
        return if let modifierGrapheme = configuration.modifierGrapheme {
            .endModifier(modifierGrapheme)
        } else if configuration.mode == .alphabetical {
            .openModifierPicker
        } else {
            .closeModifierPicker
        }
    }

    private var backspaceButton: some KeyboardLayoutElement {
        KeyboardLayoutKey(.backspace)
            .keyWidth(count: 7)
    }
}

#Preview {
    KeyboardLayoutPreviewView(
        layout: StandardKeyboardLayoutDE(),
        mode: .numerical
    )
}
