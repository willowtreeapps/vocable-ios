//
//  GazeButton.swift
//  Vocable
//
//  Created by Robert Moyer on 4/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - ButtonRole

@available(iOS, obsoleted: 15, message: "Please use the built-in ButtonRole type")
struct ButtonRole: Equatable {
    private let rawValue: String

    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    static let cancel = ButtonRole("cancel")
    static let destructive = ButtonRole("destructive")
}

// MARK: - ButtonState

struct ButtonState: OptionSet {
    let rawValue: UInt

    static let normal       = Self([])
    static let highlighted  = Self(rawValue: 1 << 0)
    static let selected     = Self(rawValue: 1 << 1)
}

// MARK: - GazeButton

struct GazeButton<Label>: UIViewRepresentable where Label: View {

    // MARK: Coordinator

    class Coordinator {
        fileprivate var cancellable: AnyCancellable?
        private let action: () -> Void

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
        minimumGazeDuration: TimeInterval = 1,
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
        let buttonStyle = context.environment.gazeButtonStyle
        let configuration = GazeButtonStyleConfiguration(label: label, state: $state, role: role)
        let styledLabel = buttonStyle.makeBody(configuration)

        let hostingController = UIHostingController(rootView: styledLabel)
        let hostingView = hostingController.view!

        let control = BridgedGazeableButton()
        control.minimumGazeDuration = minimumGazeDuration

        control.addSubview(hostingView)
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.performAction),
            for: .primaryActionTriggered
        )

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.isUserInteractionEnabled = false
        hostingView.backgroundColor = nil

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: control.leadingAnchor),
            hostingView.topAnchor.constraint(equalTo: control.topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: control.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: control.bottomAnchor)
        ])

        context.coordinator.cancellable = control
            .stateSubject
            .dropFirst()
            .sink { state in
                withAnimation(.easeIn(duration: 0.1)) {
                    self.state = state
                }
            }

        return control
    }

    func updateUIView(_ uiView: BridgedGazeableButton, context: Context) {
        uiView.isEnabled = context.environment.isEnabled
    }
}
