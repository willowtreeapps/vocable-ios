//
//  GazeButton.swift
//  Vocable
//
//  Created by Robert Moyer on 4/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import SwiftUI

class DynamicSizeHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = view.intrinsicContentSize
    }
}

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

    private typealias Configuration = GazeButtonStyleConfiguration

    class Coordinator {
        private let action: () -> Void

        fileprivate var host: DynamicSizeHostingController<AnyView>?
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
        let style = context.environment.gazeButtonStyle
        let configuration = Configuration(label: label, state: $state, role: role)
        let styledLabel = style.makeBody(configuration)
            .fixedSize()

        let hostingController = DynamicSizeHostingController(rootView: AnyView(styledLabel))
        let hostingView = hostingController.view!

        let button = BridgedGazeableButton()
        button.minimumGazeDuration = minimumGazeDuration

        button.addSubview(hostingView)
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.performAction),
            for: .primaryActionTriggered
        )

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.isUserInteractionEnabled = false
        hostingView.backgroundColor = nil

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
        let styledLabel = style.makeBody(configuration).fixedSize()

        context.coordinator.host?.rootView = AnyView(styledLabel)

        uiView.isEnabled = context.environment.isEnabled
    }
}
