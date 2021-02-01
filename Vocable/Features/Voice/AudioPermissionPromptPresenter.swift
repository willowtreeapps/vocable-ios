//
//  AudioPermissionPromptPresenter.swift
//  Vocable
//
//  Created by Chris Stroud on 1/22/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import Combine

protocol CollectionViewProvider: NSObjectProtocol {
    associatedtype CollectionViewType

    var collectionView: CollectionViewType { get }
}

protocol AudioPermissionPromptPresenter: CollectionViewProvider {

    var isDisplayingAuthorizationPrompt: Bool { get set }
}

extension AudioPermissionPromptPresenter where CollectionViewType: UICollectionView {

    func registerAuthorizationObservers() -> AnyCancellable {
        let controller = SpeechRecognitionController.shared
        let micStatusPublisher = controller.$microphonePermissionStatus.removeDuplicates()
        let speechStatusPublisher = controller.$speechPermissionStatus.removeDuplicates()
        return Publishers.CombineLatest(micStatusPublisher, speechStatusPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (micStatus, speechStatus) in
                self?.authorizationStatusDidChange(micStatus, speechStatus)
            }
    }

    func authorizationStatusDidChange(_ recordingStatus: AVAudioSession.RecordPermission, _ speechStatus: SFSpeechRecognizerAuthorizationStatus) {

        let backgroundView = speechPermissionBackgroundView(speechStatus: speechStatus) ??
            microphonePermissionBackgroundView(recordingStatus: recordingStatus) ??
            (self as? EmptyStateViewProvider)?.emptyStateView()
        
        UIView.performWithoutAnimation {
            self.collectionView.backgroundView = backgroundView
            backgroundView?.layoutIfNeeded()
        }

        isDisplayingAuthorizationPrompt = collectionView.backgroundView != nil
    }

    private func speechPermissionBackgroundView(speechStatus: SFSpeechRecognizerAuthorizationStatus) -> UIView? {
        switch speechStatus {
        case .authorized:
            return nil
        case .denied: // Need to go to settings
            return EmptyStateView(type: .speechPermissionDenied, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
        case .notDetermined: // Need to present alert
            return EmptyStateView(type: .speechPermissionUndetermined, action: {
                SpeechRecognitionController.shared.startTranscribing(requestPermission: .speech)
            })
        default:
            assertionFailure("Unsupported speech status: \(speechStatus)")
            return nil
        }
    }

    private func microphonePermissionBackgroundView(recordingStatus: AVAudioSession.RecordPermission) -> UIView? {
        switch recordingStatus {
        case .granted:
            return nil
        case .denied: // Need to go to settings
            return EmptyStateView(type: .microphonePermissionDenied, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
        case .undetermined: // Need to present alert
            return EmptyStateView(type: .microphonePermissionUndetermined, action: {
                SpeechRecognitionController.shared.startTranscribing(requestPermission: .microphone)
            })
        default:
            assertionFailure("Unknown recording status: \(recordingStatus)")
            return nil
        }
    }
}
