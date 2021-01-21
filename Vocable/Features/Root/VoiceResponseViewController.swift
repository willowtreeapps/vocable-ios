//
//  VoiceResponseViewController.swift
//  Vocable
//
//  Created by Steve Foster on 12/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Speech
import Combine

protocol VoiceResponseViewControllerDelegate: AnyObject {
    func didUpdateSpeechResponse(_ text: String?)
}

final class VoiceResponseViewController: PagingCarouselViewController {

    weak var delegate: VoiceResponseViewControllerDelegate?

    private let speechRecognizerController = SpeechRecognitionController.shared
    private var transcriptionCancellable: AnyCancellable?
    private var permissionsCancellable: AnyCancellable?

    private let machineLearningQueue = DispatchQueue(label: "machine_learning_queue", qos: .userInitiated)

    private let yesNoResponses = ["Yes", "No"]
    private let quantityResponses = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let feelingsResponses = ["Okay", "Good", "Bad"]
    private let prefixes = ["Would you like", "Do you want"]

    @PublishedValue private(set) var lastUtterance: String?
    private static let formatter = NumberFormatter()

    private(set) var isNumberResponse: Bool = false
    private(set) var choices: [String] = [] {
        didSet {
            var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
            snapshot.appendSections([0])
            snapshot.appendItems(choices)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 1.0,
                           options: [],
                           animations: { [weak self] in
                                self?.diffableDataSource.apply(snapshot, animatingDifferences: false)
                           }, completion: nil)
        }
    }

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: self.collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
        let cell = collectionView.dequeueCell(type: PresetItemCollectionViewCell.self, for: indexPath)
        cell.setup(title: item)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.all.subtracting(.top)
        view.layoutMargins.top = 4

        isPaginationViewHidden = true
        updateLayoutForCurrentTraitCollection()

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.layout.itemAnimationStyle = .shrinkExpand

        transcriptionCancellable = speechRecognizerController.$transcription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                switch newValue {
                case .partialTranscription(let transcription):
                    self?.delegate?.didUpdateSpeechResponse(transcription)
                case .finalTranscription(let transcription):
                    self?.delegate?.didUpdateSpeechResponse(transcription)
                    self?.classify(transcription: transcription)
                default:
                    break
                }
            }

        let micStatusPublisher = speechRecognizerController.$microphonePermissionStatus.removeDuplicates()
        let speechStatusPublisher = speechRecognizerController.$speechPermissionStatus.removeDuplicates()
        permissionsCancellable = Publishers.CombineLatest(micStatusPublisher, speechStatusPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (micStatus, speechStatus) in
                self?.authorizationStatusDidChange(micStatus, speechStatus)
            }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        speechRecognizerController.startTranscribing()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        speechRecognizerController.stopTranscribing()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {

        collectionView.layout.interItemSpacing = 8
        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(3)
            collectionView.layout.numberOfRows = .minimumHeight(120)
        case .hCompact_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .fixedCount(4)
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.numberOfColumns = .fixedCount(3)
            collectionView.layout.numberOfRows = .fixedCount(2)
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath != collectionView.indexPathForGazedItem {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let utterance = diffableDataSource.itemIdentifier(for: indexPath) else { return }
        lastUtterance = utterance

        DispatchQueue.global(qos: .userInitiated).async {
            AVSpeechSynthesizer.shared.speak(utterance, language: AppConfig.activePreferredLanguageCode)
        }
    }

    private func authorizationStatusDidChange(_ recordingStatus: AVAudioSession.RecordPermission, _ speechStatus: SFSpeechRecognizerAuthorizationStatus) {

        defer {
            collectionView.backgroundView?.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
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
            collectionView.backgroundView = EmptyStateView(type: .speechPermissionUndetermined, action: { [weak self] in
                self?.speechRecognizerController.startTranscribing(requestPermissions: true)
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
            collectionView.backgroundView = EmptyStateView(type: .microphonePermissionUndetermined, action: { [weak self] in
                self?.speechRecognizerController.startTranscribing(requestPermissions: true)
            })
            return
        default:
            assertionFailure("Unknown recording status: \(recordingStatus)")
        }
    }

    // MARK: ML Stubs

    private func classify(transcription: String) {

        machineLearningQueue.async { [weak self] in

            guard let self = self else { return }

            let model = try! VocableChoicesModel(configuration: .init())
            guard let prediction = try? model.prediction(text: transcription) else {
                assertionFailure("Predictions failed...")
                return
            }

            //get choices
            var sentence = transcription

            // Sanitize the sentence by removing non key words
            for prefix in self.prefixes {
                if sentence.hasPrefix(prefix) {
                    if let rangeToRemove = sentence.range(of: prefix) {
                        sentence.removeSubrange(rangeToRemove)
                    }
                }
            }

            sentence = sentence.trimmingCharacters(in: .whitespaces)
            var choicesArray = sentence.components(separatedBy: " or ")

            choicesArray = choicesArray.map { (choice) -> String in
                var sanitizedChoice = choice.trimmingCharacters(in: .whitespaces)
                if sanitizedChoice.hasPrefix("a ") {
                    if let rangeToRemove = sanitizedChoice.range(of: "a ") {
                        sanitizedChoice.removeSubrange(rangeToRemove)
                    }
                }

                if sanitizedChoice.hasSuffix("?") {
                    if let rangeToRemove = sanitizedChoice.range(of: "?") {
                        sanitizedChoice.removeSubrange(rangeToRemove)
                    }
                }

                return sanitizedChoice
            }

            DispatchQueue.main.async {
                self.choices.removeAll()

                let label = prediction.label
                if label == "boolean" {
                    print("bool")
                    self.isNumberResponse = false
                    self.choices = self.yesNoResponses
                } else if label == "quantity" {
                    print("numbers")
                    self.isNumberResponse = true
                    self.choices = self.quantityResponses
                } else if label == "feelings" {
                    print("feels")
                    self.isNumberResponse = false
                    self.choices = self.feelingsResponses
                } else if label == "choices" {
                    print("choice -> \(choicesArray)")
                    self.isNumberResponse = false
                    self.choices = choicesArray
                }
            }
        }
    }
}
