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

    case listeningResponse
    case speechServiceUnavailable
    case speechPermissionDenied
    case speechPermissionUndetermined
    case microphonePermissionDenied
    case microphonePermissionUndetermined
    case listenModeFreeResponse

    var title: String {
        #warning("Needs localization & Final copy")
        switch self {
        case .microphonePermissionUndetermined, .microphonePermissionDenied:
            return "Microphone Access"
        case .speechPermissionDenied, .speechPermissionUndetermined:
            return "Speech Recognition"
        case .listeningResponse:
            return "Listening..."
        case .listenModeFreeResponse:
            return "Sounds complicated"
        case .speechServiceUnavailable:
            return "Speech services unavailable"
        }
    }

    var description: String? {
        #warning("Needs localization & Final copy")
        switch self {
        case .microphonePermissionUndetermined:
            return "Vocable needs microphone access to enable Listening Mode. The button below presents an iOS permission dialog that Vocable's head tracking cannot interract with."
        case .microphonePermissionDenied:
            return "Vocable needs to use the microphone to enable Listening Mode. Please enable microphone access in the system Settings app.\n\nYou can also disable Listening Mode to hide this category in Vocable's settings."
        case .speechPermissionUndetermined:
            return "Vocable needs to request speech permissions to enable Listening Mode. This will present an iOS permission dialog that Vocable's head tracking cannot interract with."
        case .speechPermissionDenied:
            return "Vocable needs speech recognition to enable Listening Mode. Please enable speech recognition in the system Settings app.\n\nYou can also disable Listening Mode to hide this category in Vocable's settings."
        case .listeningResponse:
            return "When in listening mode, if someone starts speaking, Vocable will try to show quick responses."
        case .listenModeFreeResponse:
            return "Not sure what to suggest. Please repeat or use the rest of Vocable to respond."
        case .speechServiceUnavailable:
            return "Please try again later"
        }
    }

    var buttonTitle: String? {
        #warning("Needs localization & Final copy")
        switch self {
        case .listenModeFreeResponse, .listeningResponse, .speechServiceUnavailable:
            return nil
        case .microphonePermissionUndetermined, .speechPermissionUndetermined:
            return "Grant Access"
        case .microphonePermissionDenied, .speechPermissionDenied:
            return "Open Settings"
        }
    }

    var image: UIImage? {
        return nil
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
