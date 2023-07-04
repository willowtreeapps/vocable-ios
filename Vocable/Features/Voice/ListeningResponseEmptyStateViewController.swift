//
//  ListeningResponseEmptyStateViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 3/12/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import UIKit

extension EmptyStateView {
    static func listening(_ state: ListeningEmptyState, action: EmptyStateView.ButtonConfiguration) -> EmptyStateView {
        return EmptyStateView(type: state, action: action)
    }
}

enum ListeningEmptyState: EmptyStateRepresentable, Equatable {

    case listeningModeUnsupported
    case listeningResponse
    case speechServiceUnavailable
    case speechPermissionDenied
    case speechPermissionUndetermined
    case microphonePermissionDenied
    case microphonePermissionUndetermined
    case listenModeFreeResponse
    case vocableAPIFailure

    var title: String {
        switch self {
        case .listeningModeUnsupported:
            return String(localized: "listening_mode.empty_state.unsupported.title")
        case .microphonePermissionDenied:
            return String(localized: "listening_mode.empty_state.microphone_permission_denied.title")
        case .microphonePermissionUndetermined:
            return String(localized: "listening_mode.empty_state.microphone_permission_undetermined.title")
        case .speechPermissionDenied:
            return String(localized: "listening_mode.empty_state.speech_permission_denied.title")
        case .speechPermissionUndetermined:
            return String(localized: "listening_mode.empty_state.speech_permission_undetermined.title")
        case .listeningResponse:
            return String(localized: "listening_mode.empty_state.actively_listening.title")
        case .listenModeFreeResponse:
            return String(localized: "listening_mode.empty_state.free_response.title")
        case .speechServiceUnavailable:
            return String(localized: "listening_mode.empty_state.speech_unavailable.title")
        case .vocableAPIFailure:
            return String(localized: "listening_mode.empty_state.vocableAPIFailure.title")
        }
    }

    var description: String? {
        switch self {
        case .listeningModeUnsupported:
            let model = UIDevice.current.localizedModel
            let systemName = UIDevice.current.systemName
            let systemVersion = UIDevice.current.systemVersion
            let siriName = "Siri"

            let format = String(localized: "listening_mode.empty_state.unsupported.message")

            return String(format: format, model, systemName, systemVersion, siriName)
        case .microphonePermissionUndetermined:
            return String(localized: "listening_mode.empty_state.microphone_permission_undetermined.message")
        case .microphonePermissionDenied:
            return String(localized: "listening_mode.empty_state.microphone_permission_denied.message")
        case .speechPermissionUndetermined:
            return String(localized: "listening_mode.empty_state.speech_permission_undetermined.message")
        case .speechPermissionDenied:
            return String(localized: "listening_mode.empty_state.speech_permission_denied.message")
        case .listeningResponse:
            return String(localized: "listening_mode.empty_state.actively_listening.message")
        case .listenModeFreeResponse:
            return String(localized: "listening_mode.empty_state.free_response.message")
        case .speechServiceUnavailable:
            return String(localized: "listening_mode.empty_state.speech_unavailable.message")
        case .vocableAPIFailure:
            return String(localized: "listening_mode.empty_state.vocableAPIFailure.message")
        }
    }

    var buttonTitle: String? {
        switch self {
        case .listenModeFreeResponse, .listeningResponse, .listeningModeUnsupported, .speechServiceUnavailable, .vocableAPIFailure:
            return nil
        case .microphonePermissionUndetermined:
            return String(localized: "listening_mode.empty_state.microphone_permission_undetermined.action")
        case .speechPermissionUndetermined:
            return String(localized: "listening_mode.empty_state.speech_permission_undetermined.action")
        case .microphonePermissionDenied:
            return String(localized: "listening_mode.empty_state.microphone_permission_denied.action")
        case .speechPermissionDenied:
            return String(localized: "listening_mode.empty_state.speech_permission_denied.action")
        }
    }

    var image: UIImage? {
        return nil
    }

    var yOffset: CGFloat? {
        switch self {
        case .listeningModeUnsupported:
            return -64
        default:
            return nil
        }
    }
}

final class ListeningResponseEmptyStateViewController: UIViewController {

    private(set) var state: ListeningEmptyState
    private let buttonAction: EmptyStateView.ButtonConfiguration

    init(state: ListeningEmptyState, action: EmptyStateView.ButtonConfiguration) {
        self.state = state
        self.buttonAction = action
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = EmptyStateView(type: state, action: buttonAction)
    }
}
