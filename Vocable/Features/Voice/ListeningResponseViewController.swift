//
//  ListeningResponseViewController.swift
//  Vocable
//
//  Created by Steve Foster on 12/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Speech
import Combine
import VocableListenCore

protocol ListeningResponseViewControllerDelegate: AnyObject {
    func didUpdateSpeechResponse(_ text: String?)
}

@available(iOS 14.0, *)
final class ListeningResponseViewController: PagingCarouselViewController, AudioPermissionPromptPresenter, EmptyStateViewProvider {

    private enum Content {
        case choices([String])
        case empty(EmptyStateView.EmptyStateType)
    }

    weak var delegate: ListeningResponseViewControllerDelegate?

    private let speechRecognizerController = SpeechRecognitionController.shared
    private var transcriptionCancellable: AnyCancellable?
    private var permissionsCancellable: AnyCancellable?
    private var classificationCancellable: AnyCancellable?
    private var availabilityCancellable: AnyCancellable?

    private var desiredEmptyStateView: UIView? {
        didSet {
            if collectionView.backgroundView == oldValue {
                collectionView.backgroundView = desiredEmptyStateView
            }
        }
    }

    private var emptyState: EmptyStateView.EmptyStateType?

    private let synthesizedSpeechQueue = DispatchQueue(label: "speech_synthesis_queue", qos: .userInitiated)
    let classifier = VLClassifier()

    private let feelingsResponses = ["Okay", "Good", "Bad"]
    private let prefixes = ["Would you like", "Do you want"]

    internal var isDisplayingAuthorizationPrompt = false {
        didSet {
            if speechRecognizerController.isAvailable {
                content = .empty(.listeningResponse)
            }
        }
    }

    @PublishedValue private(set) var lastUtterance: String?

    private var content: Content = .empty(.listeningResponse) {
        didSet {
            switch content {
            case .choices(let choices):
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
                desiredEmptyStateView = nil
            case .empty(let emptyStateType):
                desiredEmptyStateView = EmptyStateView(type: emptyStateType)
            }
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if permissionsCancellable == nil {
            permissionsCancellable = registerAuthorizationObservers()
        }

        if transcriptionCancellable == nil {
            transcriptionCancellable = speechRecognizerController.$transcription
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newValue in
                    guard let self = self else { return }
                    switch newValue {
                    case .partialTranscription(let transcription):
                        self.delegate?.didUpdateSpeechResponse(transcription)
                    case .finalTranscription(let transcription):
                        self.delegate?.didUpdateSpeechResponse(transcription)
                        self.classifier.classify(transcription)
                    default:
                        if self.speechRecognizerController.isListening {
                            self.content = .empty(.listeningResponse)
                        }
                    }
                }
        }

        if classificationCancellable == nil {
            classificationCancellable = classifier.$classification
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] newValue in
                    self?.updateResponses(for: newValue)
                }
        }

        if availabilityCancellable == nil {
            availabilityCancellable = speechRecognizerController.$isAvailable
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isAvailable in
                    guard let self = self else { return }
                    if isAvailable {
                        if case .choices = self.content {
                            // no-op
                        } else {
                            self.content = .empty(.listeningResponse)
                        }
                    } else {
                        if case .empty(let emptyKind) = self.content {
                            switch emptyKind {
                            case .speechServiceUnavailable:
                                return
                            case .speechPermissionDenied:
                                return
                            case .speechPermissionUndetermined:
                                return
                            case .microphonePermissionDenied:
                                return
                            case .microphonePermissionUndetermined:
                                return
                            default:
                                break
                            }
                        }
                        self.content = .empty(.speechServiceUnavailable)
                    }
                }
        }

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

        synthesizedSpeechQueue.async {
            AVSpeechSynthesizer.shared.speak(utterance, language: AppConfig.activePreferredLanguageCode)
        }
    }

    func emptyStateView() -> UIView? {
        return desiredEmptyStateView
    }

    // MARK: ML Stubs

    private func updateResponses(for result: VLClassificationResult?) {

        guard let result = result else {
            content = .empty(.listeningResponse)
            return
        }

        switch result.result {
        case .freeResponse:
            updateForFreeResponse(result)
        case .yesOrNo:
            content = .choices(["Yes", "No"])
        case .numerical:
            content = .choices(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"])
        case .interval:
            content = .choices(["1", "2", "3", "4", "5"])
        @unknown default:
            content = .empty(.listeningResponse)
        }
    }

    private func updateForFreeResponse(_ result: VLClassificationResult) {

        // Placeholder to try and preserve this functionality from the
        // demo model until the new model supports it
        guard result.text.contains(" or ") else {
            content = .empty(.listenModeFreeResponse)
            return
        }

        var sentence = result.text.trimmingCharacters(in: .whitespaces)

        // Sanitize the sentence by removing non key words
        for prefix in self.prefixes {
            if sentence.hasPrefix(prefix) {
                if let rangeToRemove = sentence.range(of: prefix) {
                    sentence.removeSubrange(rangeToRemove)
                }
            }
        }

        sentence = sentence.trimmingCharacters(in: .whitespaces)

        let operands = sentence.components(separatedBy: " or ")

        let choices = operands.map { (choice) -> String in
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
        content = .choices(choices)
    }
}
