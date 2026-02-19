//
//  PersonalVoicePermissionPromptController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/26/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import UIKit

@available(iOS 17.0, *)
final class PersonalVoicePermissionPromptController {
    
    private typealias AuthorizationStatus = AVSpeechSynthesizer.PersonalVoiceAuthorizationStatus
    
    struct PersonalVoicePermissionEmptyState {
        let state: PersonalVoiceEmptyState
        let action: EmptyStateView.ButtonConfiguration
    }

    @Published private(set) var state: PersonalVoicePermissionEmptyState? = .none

    private var cancellables = Set<AnyCancellable>()

    private var authorizationStatus: AuthorizationStatus {
        AVSpeechSynthesizer.personalVoiceAuthorizationStatus
    }
    
    init() {
        self.authorizationStatusDidChange(authorizationStatus)
        NotificationCenter.default
            .publisher(
                for: AVSpeechSynthesizer.availableVoicesDidChangeNotification,
                object: nil
            )
            .compactMap { [weak self] _ in
                self?.authorizationStatus
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status) in
                self?.authorizationStatusDidChange(status)
            }
            .store(in: &cancellables)
    }

    private func authorizationStatusDidChange(_ status: AuthorizationStatus) {
        switch status {
        case .authorized:
            self.state = nil
        case .denied: // Need to go to settings
            self.state = .init(state: .denied) {
                UIApplication.openSettingsURL()
            }
        case .notDetermined: // Need to present alert
            self.state = .init(state: .notAuthorized) { [weak self] in
                AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                    self?.authorizationStatusDidChange(status)
                }
            }
        case .unsupported: // Device or OS does not support Personal Voice
            self.state = .init(state: .unsupported) { }
        @unknown default:
            self.state = nil
        }
    }
}
