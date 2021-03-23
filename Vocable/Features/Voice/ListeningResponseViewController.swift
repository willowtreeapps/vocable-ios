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
final class ListeningResponseViewController: VocableViewController {

    private enum Content: Equatable {
        case choices([String])
        case empty(ListeningEmptyState, action: EmptyStateView.ButtonConfiguration = nil)

        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.choices(let items_lhs), .choices(let items_rhs)):
                return items_lhs == items_rhs
            case (.empty(let state_lhs, _), .empty(let state_rhs, _)):
                return state_lhs == state_rhs
            default:
                return false
            }
        }
    }

    weak var delegate: ListeningResponseViewControllerDelegate?

    private let permissionsController = AudioPermissionPromptController()
    private let speechRecognizerController = SpeechRecognitionController.shared
    private var transcriptionCancellable: AnyCancellable?
    private var permissionsCancellable: AnyCancellable?
    private var classificationCancellable: AnyCancellable?
    private var availabilityCancellable: AnyCancellable?

    private var contentViewController: UIViewController?
    private lazy var contentViewLayoutGuide: UILayoutGuide = {
        let guide = UILayoutGuide()
        self.view.addLayoutGuide(guide)
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: self.view.topAnchor),
            guide.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            guide.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        return guide
    }()

    private var emptyState: ListeningEmptyState?

    private let synthesizedSpeechQueue = DispatchQueue(label: "speech_synthesis_queue", qos: .userInitiated)
    let classifier = VLClassifier()

    private let feelingsResponses = ["Okay", "Good", "Bad"]
    private let prefixes = ["Would you like", "Do you want"]

    @PublishedValue private(set) var lastUtterance: String?

    private var content: Content = .empty(.listeningResponse)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.clipsToBounds = true
        
        edgesForExtendedLayout = UIRectEdge.all.subtracting(.top)
        view.layoutMargins.top = 4
    }

    private func setContent(_ content: Content, animated: Bool = true) {

        if self.contentViewController != nil {
            guard content != self.content else {
                return
            }
        }

        self.content = content

        switch content {
        case .choices(let choices):
            let viewController = ListeningResponseContentViewController()
            viewController.content = choices
            viewController.synthesizedSpeechQueue = synthesizedSpeechQueue
            viewController.$lastUtterance
                .sink { [weak self] utterance in
                    self?.lastUtterance = utterance
                }
                .store(in: &viewController.disposables)
            setContentViewController(viewController, animated: animated)
        case .empty(let state, let action):
            let viewController = ListeningResponseEmptyStateViewController(state: state, action: action)
            setContentViewController(viewController, animated: animated)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let initialContent: Content = {
            if let status = permissionsController.state {
                return .empty(status.state, action: status.action)
            }
            if !speechRecognizerController.isAvailable {
                return .empty(.speechServiceUnavailable)
            }
            return .empty(.listeningResponse)
        }()

        setContent(initialContent, animated: false)

        observePermissions()

        observeTranscription()
        observeClassification()
        observeAvailability()
        speechRecognizerController.startTranscribing()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        speechRecognizerController.stopTranscribing()
    }

    private func observeClassification() {
        guard classificationCancellable == nil else { return }
        classificationCancellable = classifier.classificationPublisher
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.updateResponses(for: newValue)
            }
    }

    private func observeTranscription() {
        guard transcriptionCancellable == nil else { return }

        transcriptionCancellable = speechRecognizerController.$transcription
            .dropFirst()
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
                        self.setContent(.empty(.listeningResponse), animated: true)
                    }
                }
            }
    }

    private func observeAvailability() {

        guard availabilityCancellable == nil else { return }

        availabilityCancellable = speechRecognizerController.$isAvailable
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAvailable in
                guard let self = self else { return }
                if isAvailable {
                    if case .choices = self.content {
                        // no-op
                    } else {
                        self.setContent(.empty(.listeningResponse), animated: true)
                    }
                } else {
                    if case .empty(let emptyKind, _) = self.content {
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
                    self.setContent(.empty(.speechServiceUnavailable), animated: true)
                }
            }
    }

    private func observePermissions() {
        guard permissionsCancellable == nil else {
            return
        }
        permissionsCancellable = permissionsController.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                if let newValue = newValue {
                    self?.setContent(.empty(newValue.state, action: newValue.action), animated: true)
                } else {
                    self?.setContent(.empty(.listeningResponse), animated: true)
                }
            }
    }

    // MARK: ML Stubs

    private func updateResponses(for result: VLClassificationResult?) {

        var content: Content? = .none
        defer {
            if let content = content {
                self.setContent(content, animated: true)
            }
        }

        guard let result = result else {
            content = .empty(.listeningResponse)
            return
        }

        ListenModeDebugStorage.shared.contexts.append(result.context)

        guard let responses = result.responses, !responses.isEmpty else {
            content = .empty(.listenModeFreeResponse)
            return
        }

        content = .choices(responses)
    }

    private func setContentViewController(_ viewController: UIViewController?, animated: Bool) {

        let childrenToDisposeOf = children.filter {
            ![viewController].contains($0)
        }

        let layoutGuide = self.contentViewLayoutGuide
        let exitTransform = CGAffineTransform.identity
            .translatedBy(x: 0, y: -layoutGuide.layoutFrame.height)

        let contentTransform = CGAffineTransform.identity
        let entranceTransform = CGAffineTransform.identity
            .scaledBy(x: 0.8, y: 0.8)
            .translatedBy(x: 0, y: layoutGuide.layoutFrame.height)

        let contentAlpha: CGFloat = 1
        let exitAlpha: CGFloat = .zero
        let entranceAlpha: CGFloat = .zero

        func prepare() {
            if let viewController = viewController {
                installViewController(viewController, in: layoutGuide)
                if animated {
                    viewController.view.transform = entranceTransform
                    viewController.view.alpha = entranceAlpha
                }
            }
        }

        func actions() {
            if let viewController = viewController {
                viewController.view.transform = contentTransform
                viewController.view.alpha = contentAlpha
            }
            for inactiveViewController in childrenToDisposeOf {
                inactiveViewController.view.transform = exitTransform
                inactiveViewController.view.alpha = exitAlpha
            }
        }

        func finalize(_ didFinish: Bool) {
            for inactiveViewController in childrenToDisposeOf {
                inactiveViewController.removeFromParent()
                inactiveViewController.view.removeFromSuperview()
            }
            self.contentViewController = viewController
        }

        prepare()
        UIView.animate(withDuration: 1.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: actions,
                       completion: finalize)
    }

    private func installViewController(_ viewController: UIViewController, in layoutGuide: UILayoutGuide) {

        addChild(viewController)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.removeFromSuperview()
        view.addSubview(viewController.view)

        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            viewController.view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
        viewController.view.layoutIfNeeded()
    }
}
