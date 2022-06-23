//
//  GazeButtonStyle.swift
//  Vocable
//
//  Created by Robert Moyer on 4/4/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

// MARK: - GazeButtonStyle

/// A type that applies a custom appearance to all ``GazeButton`` instances
/// within a view hierarchy.
///
/// To configure the style for a single ``GazeButton`` or for all gaze button
/// instances in a view hierarchy, use the `gazeButtonStyle(_:)` modifier. You
/// can specify one of the built-in button styles, like ``GazeButtonStyle/vocable``:
///
///     GazeButton("Sign In", action: signIn)
///         .gazeButtonStyle(.vocable)
///
/// Alternatively, you can create and apply a custom style.
///
/// ### Custom Styles
///
/// To create a custom style, declare a type that conforms to the `GazeButtonStyle`
/// protocol and implement the required ``GazeButtonStyle/makeBody(_:)`` method.
/// For example, you can define a bordered prominent button style:
///
///     struct BorderedProminentGazeButtonStyle: GazeButtonStyle {
///         func makeBody(_ configuration: Configuration) -> some View {
///             // Return a view with a bordered prominent style
///         }
///     }
///
/// Inside the method, use the configuration parameter to get the label, the
/// button role, and a binding to the button state. To see examples of how to
/// use these items to construct a view that has the appearance and behavior
/// of a button, see ``GazeButtonStyle/makeBody(_:)``.
///
/// To provide easy access to the new style, declare a corresponding static
/// variable in an extension on `GazeButtonStyle`:
///
///     extension GazeButtonStyle where Self == BorderedProminentGazeButtonStyle {
///         static var borderedProminent: BorderedProminentGazeButtonStyle { .init() }
///     }
///
/// You can then use your custom style:
///
///     GazeButton("Tap here", action: handleButtonTap)
///         .gazeButtonStyle(.borderedProminent)
///
protocol GazeButtonStyle {

    /// A view that represents the appearance of a ``GazeButton``.
    ///
    /// SwiftUI infers this type automatically based on the `View`
    /// instance that you return from your implementation of the
    /// ``makeBody(_:)`` method.
    associatedtype Body: View

    /// The properties of a ``GazeButton``.
    ///
    /// You receive a `configuration` parameter of this type --- which is an
    /// alias for the ``GazeButtonStyleConfiguration`` type --- when you
    /// implement the required ``makeBody(_:)`` method in a custom toggle
    /// style implementation.
    typealias Configuration = GazeButtonStyleConfiguration

    /// Creates a view that represents the body of a ``GazeButton``.
    ///
    /// Implement this method when you define a custom gaze button style that
    /// conforms to the ``GazeButtonStyle`` protocol. Use the `configuration`
    /// input --- a ``GazeButtonStyleConfiguration`` instance --- to access the
    /// buttons's label, role, and state. Return a view that has the appearance and
    /// behavior of a button. For example, you can define a bordered prominent button
    /// style:
    ///
    ///     struct BorderedProminentGazeButtonStyle: GazeButtonStyle {
    ///       func makeBody(_ configuration: Configuration) -> some View {
    ///         configuration.label
    ///           .foregroundColor(.white)
    ///           .padding(.horizontal, 12)
    ///           .padding(.vertical, 8)
    ///           .background(
    ///             RoundedRectangle(cornerRadius: 8)
    ///               .fill(Color.accentColor)
    ///           )
    ///         }
    ///     }
    ///
    /// When updating a view hierarchy, the system calls your implementation
    /// of the ``makeBody(_:)`` method for each ``GazeButton`` instance
    /// that uses the associated style.
    ///
    /// - Parameter configuration: The properties of the ``GazeButton``,
    ///   including a label, the button's role, and a binding to the
    ///   buttons's state.
    /// - Returns: A view that has behavior and appearance that enables it
    ///   to function as a button.
    @ViewBuilder func makeBody(_ configuration: Configuration) -> Body
}

// MARK: - View Modifier

extension View {
    /// Sets the style for GazeButton instances within a view hierarchy.
    ///
    /// Use this modifier to set a specific style for button instances
    /// within a container view:
    ///
    ///     HStack {
    ///         GazeButton("Sign In", action: signIn)
    ///         GazeButton("Register", action: register)
    ///     }
    ///     .gazeButtonStyle(.vocable)
    ///
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
