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

// MARK: - View Modifier

extension View {
    func gazeButtonStyle<Style: GazeButtonStyle>(_ style: Style) -> some View {
        environment(\.gazeButtonStyle, AnyGazeButtonStyle(style))
    }
}

// MARK: - Environment Values

extension EnvironmentValues {
    private struct GazeButtonStyleKey: EnvironmentKey {
        static var defaultValue = AnyGazeButtonStyle(.automatic)
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
