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
