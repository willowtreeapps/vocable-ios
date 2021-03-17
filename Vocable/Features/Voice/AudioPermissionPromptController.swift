//
//  AudioPermissionPromptController.swift
//  Vocable
//
//  Created by Chris Stroud on 1/22/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import Combine

final class AudioPermissionPromptController {

    struct AudioPermissionEmptyState {
        let state: ListeningEmptyState
        let action: EmptyStateView.ButtonConfiguration
    }

    @Published private(set) var state: AudioPermissionEmptyState? = .none

    private var cancellables = Set<AnyCancellable>()

    init() {
        let controller = SpeechRecognitionController.shared
        self.authorizationStatusDidChange(controller.microphonePermissionStatus, controller.speechPermissionStatus)
        let micStatusPublisher = controller.$microphonePermissionStatus.dropFirst().removeDuplicates()
        let speechStatusPublisher = controller.$speechPermissionStatus.dropFirst().removeDuplicates()
        Publishers.CombineLatest(micStatusPublisher, speechStatusPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (micStatus, speechStatus) in
                self?.authorizationStatusDidChange(micStatus, speechStatus)
            }.store(in: &cancellables)
    }

    private func authorizationStatusDidChange(_ recordingStatus: AVAudioSession.RecordPermission, _ speechStatus: SFSpeechRecognizerAuthorizationStatus) {
        self.state = speechState(speechStatus: speechStatus) ?? microphoneState(recordingStatus: recordingStatus)
    }

    private func speechState(speechStatus: SFSpeechRecognizerAuthorizationStatus) -> AudioPermissionEmptyState? {
        switch speechStatus {
        case .authorized:
            return nil
        case .denied: // Need to go to settings
            return .init(state: .speechPermissionDenied, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
        case .notDetermined: // Need to present alert
            return .init(state: .speechPermissionUndetermined, action: {
                SpeechRecognitionController.shared.startTranscribing(requestPermission: .speech)
            })
        default:
            assertionFailure("Unsupported speech status: \(speechStatus)")
            return nil
        }
    }

    private func microphoneState(recordingStatus: AVAudioSession.RecordPermission) -> AudioPermissionEmptyState? {
        switch recordingStatus {
        case .granted:
            return nil
        case .denied: // Need to go to settings
            return .init(state: .microphonePermissionDenied, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
        case .undetermined: // Need to present alert
            return .init(state: .microphonePermissionUndetermined, action: {
                SpeechRecognitionController.shared.startTranscribing(requestPermission: .microphone)
            })
        default:
            assertionFailure("Unknown recording status: \(recordingStatus)")
            return nil
        }
    }
}
