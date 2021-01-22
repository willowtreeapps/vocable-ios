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

        defer {
            collectionView.backgroundView?.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
            isDisplayingAuthorizationPrompt = collectionView.backgroundView != nil
        }

        switch speechStatus {
        case .authorized:
            collectionView.backgroundView = nil
        case .denied: // Need to go to settings
            collectionView.backgroundView = EmptyStateView(type: .speechPermissionDenied, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
            return
        case .notDetermined: // Need to present alert
            collectionView.backgroundView = EmptyStateView(type: .speechPermissionUndetermined, action: {
                SpeechRecognitionController.shared.startTranscribing(requestPermissions: true)
            })
            return
        default:
            assertionFailure("Unsupported speech status: \(recordingStatus)")
        }

        switch recordingStatus {
        case .granted:
            collectionView.backgroundView = nil
        case .denied: // Need to go to settings
            collectionView.backgroundView = EmptyStateView(type: .microphonePermissionDenied, action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
            return
        case .undetermined: // Need to present alert
            collectionView.backgroundView = EmptyStateView(type: .microphonePermissionUndetermined, action: {
                SpeechRecognitionController.shared.startTranscribing(requestPermissions: true)
            })
            return
        default:
            assertionFailure("Unknown recording status: \(recordingStatus)")
        }
    }
}
