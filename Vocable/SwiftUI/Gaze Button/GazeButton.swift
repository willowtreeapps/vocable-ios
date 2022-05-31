//
//  GazeButton.swift
//  Vocable
//
//  Created by Robert Moyer on 4/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - GazeButton

/// A control that initiates an action from a touch or head-gaze event.
///
/// You create a button by providing an action and a label. The action is either
/// a method or closure property that does something when a user clicks or taps
/// the button. The label is a view that describes the button's action --- for
/// example, by showing text, an icon, or both:
///
///     GazeButton(action: signIn) {
///         Text("Sign In")
///     }
///
/// For the common case of text-only labels, you can use the convenience
/// initializer that takes a title string or `LocalizedStringKey` as its first
/// parameter, instead of a trailing closure:
///
///     GazeButton("Sign In", action: signIn)
///
/// ### Assigning a Role
///
/// You can optionally initialize a button with a ``ButtonRole`` that
/// characterizes the button's purpose. For example, you can create a
/// ``ButtonRole/destructive`` button for a deletion action:
///
///      GazeButton("Delete", role: .destructive, action: delete)
///
/// The button's role is used to style the button appropriately. For
/// example, a destructive button in the default style appears with
/// a red foreground color:
///
/// ![A screenshot of a menu that contains the four items Cut, Copy,
/// Paste, and Delete. The last item uses a foreground color of red.](GazeButton-Roles)
///
/// If you don't specify a role for a button, an appropriate default
/// appearance is used.
///
/// ### Styling Buttons
///
/// You can customize a button's appearance using one of the included button
/// styles, like ``GazeButtonStyle/vocable``, and apply the style with the
/// `gazeButtonStyle(_:)` modifier:
///
///     HStack {
///         GazeButton("Sign In", action: signIn)
///         GazeButton("Register", action: register)
///     }
///     .gazeButtonStyle(.vocable)
///
/// If you apply the style to a container view, as in the example above,
/// all the buttons in the container use the style:
///
/// ![A screenshot of two buttons, side by side. The label for the first
/// button is Sign In; the right button is Register.](GazeButton-Styling)
///
/// You can also create custom styles. To add a custom appearance, create
/// a style that conforms to the ``GazeButtonStyle`` protocol.
struct GazeButton<Label>: UIViewRepresentable where Label: View {

    // MARK: Subtypes

    private typealias Configuration = GazeButtonStyleConfiguration

    class Coordinator {
        private let action: () -> Void

        fileprivate var host: ContentHuggingHostingController<AnyView>?
        fileprivate var cancellable: AnyCancellable?

        init(_ action: @escaping () -> Void) {
            self.action =  action
        }

        @objc fileprivate func performAction() {
            action()
        }
    }

    // MARK: Properties

    @State private var state: ButtonState = .normal

    private let minimumGazeDuration: TimeInterval
    private let action: () -> Void
    private let label: Label
    private let role: ButtonRole?

    // MARK: Initializer

    init(
        minimumGazeDuration: TimeInterval = AppConfig.selectionHoldDuration,
        role: ButtonRole? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.minimumGazeDuration = minimumGazeDuration
        self.role = role
        self.action = action
        self.label = label()
    }

    // MARK: UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(action)
    }

    func makeUIView(context: Context) -> BridgedGazeableButton {
        let style = context.environment.gazeButtonStyle
        let configuration = Configuration(label: label, state: $state, role: role)
        let styledLabel = style.makeBody(configuration)

        let hostingController = ContentHuggingHostingController(rootView: AnyView(styledLabel))
        let hostingView = hostingController.view!

        let button = BridgedGazeableButton()
        button.minimumGazeDuration = minimumGazeDuration

        button.addSubview(hostingView)
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.performAction),
            for: .primaryActionTriggered
        )

        hostingView.backgroundColor = nil
        hostingView.isUserInteractionEnabled = false
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            hostingView.topAnchor.constraint(equalTo: button.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])

        context.coordinator.host = hostingController
        context.coordinator.cancellable = button
            .stateSubject
            .dropFirst()
            .sink { state in
                withAnimation(.easeIn(duration: 0.1)) {
                    self.state = state
                }
            }

        return button
    }

    func updateUIView(_ uiView: BridgedGazeableButton, context: Context) {
        let style = context.environment.gazeButtonStyle
        let configuration = Configuration(label: label, state: $state, role: role)
        let styledLabel = style.makeBody(configuration)

        context.coordinator.host?.rootView = AnyView(styledLabel)

        uiView.isEnabled = context.environment.isEnabled

        uiView.setContentHuggingPriority(
            context.environment.horizontalContentHuggingPriority,
            for: .horizontal
        )

        uiView.setContentHuggingPriority(
            context.environment.verticalContentHuggingPriority,
            for: .vertical
        )
    }
}

// MARK: Convenience Inits

extension GazeButton {
    init(
        _ titleKey: LocalizedStringKey,
        minimumGazeDuration: TimeInterval = AppConfig.selectionHoldDuration,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) where Label == Text {
        self.init(minimumGazeDuration: minimumGazeDuration, role: role, action: action) {
            Text(titleKey)
        }
    }

    init<S: StringProtocol>(
        _ title: S,
        minimumGazeDuration: TimeInterval = AppConfig.selectionHoldDuration,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) where Label == Text {
        self.init(minimumGazeDuration: minimumGazeDuration, role: role, action: action) {
            Text(title)
        }
    }
}
