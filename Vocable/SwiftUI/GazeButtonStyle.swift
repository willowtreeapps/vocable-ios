//
//  GazeButtonStyle.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

// MARK: - GazeButtonStyle

protocol GazeButtonStyle {
    associatedtype Body: View
    typealias Configuration = GazeButtonStyleConfiguration

    @ViewBuilder func makeBody(_ configuration: Configuration) -> Body
}

struct DefaultGazeButtonStyle: GazeButtonStyle {
    private struct _Body<Label: View>: View {
        @Environment(\.isEnabled)
        private var isEnabled

        @Binding var state: ButtonState

        var label: Label

        var body: some View {
            label
                .foregroundColor(.accentColor)
                .opacity(
                    (state.contains(.highlighted) || !isEnabled) ? 0.3 : 1
                )
        }
    }

    func makeBody(_ configuration: Configuration) -> some View {
        _Body(state: configuration.state, label: configuration.label)
    }
}

// MARK: - Configuration

struct GazeButtonStyleConfiguration {
    struct Label: View {
        private var view: AnyView
        var body: some View { view }

        fileprivate init<V: View>(_ view: V) {
            self.view = AnyView(view)
        }
    }

    let state: Binding<ButtonState>
    let label: Label

    init<V: View>(label: V, state: Binding<ButtonState>) {
        self.label = Label(label)
        self.state = state
    }
}

// MARK: - View Modifier

extension View {
    func gazeButtonStyle<Style: GazeButtonStyle>(_ style: Style) -> some View {
        environment(\.gazeButtonStyle, AnyGazeButtonStyle(style))
    }
}

// MARK: - Environment Values

extension EnvironmentValues {
    private struct GazeButtonStyleKey: EnvironmentKey {
        static var defaultValue = AnyGazeButtonStyle(DefaultGazeButtonStyle())
    }

    var gazeButtonStyle: AnyGazeButtonStyle {
        get { self[GazeButtonStyleKey.self] }
        set { self[GazeButtonStyleKey.self] = newValue }
    }
}

// MARK: - Type Erasure

struct AnyGazeButtonStyle: GazeButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<Style: GazeButtonStyle>(_ style: Style) {
        self._makeBody = { AnyView(style.makeBody($0)) }
    }

    func makeBody(_ configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}
