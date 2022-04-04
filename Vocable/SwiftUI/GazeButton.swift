//
//  GazeButton.swift
//  Vocable
//
//  Created by Robert Moyer on 4/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - ControlState

struct ControlState: OptionSet {
    let rawValue: UInt

    static let normal       = Self([])
    static let highlighted  = Self(rawValue: 1 << 0)
    static let disabled     = Self(rawValue: 1 << 1)
    static let selected     = Self(rawValue: 1 << 2)
}

// MARK: - GazeButton

struct GazeButton<Label>: UIViewRepresentable where Label: View {

    // MARK: Coordinator

    class Coordinator {
        fileprivate var hostingController: UIHostingController<AnyView>?
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

    @State private var state: ControlState = .normal

    @Environment(\.gazeButtonStyle)
    private var buttonStyle

    private let minimumGazeDuration: TimeInterval
    private let action: () -> Void
    private let label: Label

    // MARK: Initializer

    init(
        minimumGazeDuration: TimeInterval = 1,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.minimumGazeDuration = minimumGazeDuration
        self.action = action
        self.label = label()
    }

    // MARK: UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(action)
    }

    func makeUIView(context: Context) -> BridgedGazeableButton {
        let configuration = GazeButtonStyleConfiguration(label: label, state: $state)
        let labelBody = buttonStyle.makeBody(configuration)
        let hostingController = UIHostingController(rootView: AnyView(labelBody))
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

        context.coordinator.hostingController = hostingController
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

    func updateUIView(_ uiView: BridgedGazeableButton, context: Context) { /* No op */ }
}
