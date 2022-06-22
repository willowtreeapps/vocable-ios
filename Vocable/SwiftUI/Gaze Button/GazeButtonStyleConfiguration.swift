//
//  GazeButtonStyleConfiguration.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import SwiftUI

/// The properties of a ``GazeButton`` instance.
///
/// When you define a custom button style by creating a type that conforms to
/// the ``GazeButtonStyle`` protocol, you implement the
/// ``GazeButtonStyle/makeBody(_:)`` method. That method takes a
/// `GazeButtonStyleConfiguration` input that has the information you need
/// to define the behavior and appearance of a ``GazeButton``.
///
/// The configuration structure's ``label-swift.property`` reflects the
/// button's content, which might be the value that you supply to the
/// `label` parameter of the ``GazeButton/init(minimumGazeDuration:role:action:label:)`` initializer.
/// Alternatively, it could be another view that SwiftUI builds from an
/// initializer that takes a string input, like ``GazeButton/init(_:minimumGazeDuration:role:action:)-9hl39``.
/// In either case, incorporate the label into the button's view to help
/// the user understand that the view is interactive.
///
/// The structure's ``state`` property provides a `Binding` to the state
/// of the button. Adjust the appearance of the button based on this value.
/// For example, the built-in ``GazeButtonStyle/vocable`` style adds a thick
/// border and shrinks the size when the vaule ``ButtonState/highlighted``.
struct GazeButtonStyleConfiguration {

    /// A type-erased label of a ``GazeButton``.
    struct Label: View {
        private var view: AnyView
        var body: some View { view }

        fileprivate init<V: View>(_ view: V) {
            self.view = AnyView(view)
        }
    }

    /// A binding to a state property that indicates whether the
    /// button is highlighted or pressed.
    let state: Binding<ButtonState>

    /// A view that describes the effect of pressing the button.
    let label: Label

    /// An optional semantic role that describes the button’s purpose.
    let role: ButtonRole?

    init<V: View>(label: V, state: Binding<ButtonState>, role: ButtonRole?) {
        self.label = Label(label)
        self.state = state
        self.role = role
    }
}
