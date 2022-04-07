//
//  DefaultGazeButtonStyle.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

struct DefaultGazeButtonStyle: GazeButtonStyle {
    private struct _Body<Label: View>: View {
        @Environment(\.isEnabled)
        private var isEnabled

        @Binding var state: ButtonState

        var label: Label
        var buttonRole: ButtonRole?

        var body: some View {
            label
                .foregroundColor(buttonRole == .destructive ? .red : .accentColor)
                .opacity(
                    (state.contains(.highlighted) || !isEnabled) ? 0.3 : 1
                )
        }
    }

    func makeBody(_ configuration: Configuration) -> some View {
        _Body(state: configuration.state, label: configuration.label, buttonRole: configuration.role)
    }
}

extension GazeButtonStyle where Self == DefaultGazeButtonStyle {
    static var automatic: DefaultGazeButtonStyle { .init() }
}
