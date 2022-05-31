//
//  DefaultGazeButtonStyle.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

/// The default button style.
///
/// You can also use ``GazeButtonStyle/automatic`` to construct this style.
struct DefaultGazeButtonStyle: GazeButtonStyle {
    func makeBody(_ configuration: Configuration) -> some View {
        _Body(configuration)
    }

    private struct _Body<Label: View>: View {
        @Environment(\.isEnabled)
        private var isEnabled

        @Binding var state: ButtonState

        var label: Label
        var buttonRole: ButtonRole?

        init(_ configuration: Configuration) where Configuration.Label == Label {
            self._state = configuration.state
            self.label = configuration.label
            self.buttonRole = configuration.role
        }

        var body: some View {
            label
                .foregroundColor(buttonRole == .destructive ? .red : .accentColor)
                .opacity(
                    (state.contains(.highlighted) || !isEnabled) ? 0.5 : 1
                )
        }
    }
}

extension GazeButtonStyle where Self == DefaultGazeButtonStyle {
    /// The default button style
    static var automatic: DefaultGazeButtonStyle { .init() }
}
