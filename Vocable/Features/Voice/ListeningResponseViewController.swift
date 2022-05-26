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

    enum Content: Equatable {
        case numerical
        case choices([String])
        case empty(ListeningEmptyState, action: EmptyStateView.ButtonConfiguration = nil)

        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.choices(let items_lhs), .choices(let items_rhs)):
                return items_lhs == items_rhs
            case (.empty(let state_lhs, _), .empty(let state_rhs, _)):
                return state_lhs == state_rhs
            case (.numerical, .numerical):
                return true
            default:
                return false
            }
        }
    }

    private struct TransitionAnimator {

        let propertyAnimator: UIViewPropertyAnimator
        let preflightActions: () -> Void
        let delay: TimeInterval

        init(propertyAnimator: UIViewPropertyAnimator, preflightActions: @escaping () -> Void, delay: TimeInterval = .zero) {
            self.propertyAnimator = propertyAnimator
            self.preflightActions = preflightActions
            self.delay = delay
        }

        func withDelay(_ delay: TimeInterval) -> TransitionAnimator {
            return TransitionAnimator(propertyAnimator: propertyAnimator, preflightActions: preflightActions, delay: delay)
        }
    }

    private enum TransitionStyle {
        case none
        case timeline
        case inline
    }

    private var transitionAnimators = Set<UIViewPropertyAnimator>()

    weak var delegate: ListeningResponseViewControllerDelegate?

    private let permissionsController = AudioPermissionPromptController(mode: .transcribing)
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
        let previousContent = self.content
        self.content = content
        let outgoingTransition: TransitionStyle
        let incomingTransition: TransitionStyle

        if animated {

            if case .empty = previousContent {
                outgoingTransition = .inline
            } else {
                outgoingTransition = .timeline
            }

            if case .empty = content {
                incomingTransition = .inline
            } else {
                incomingTransition = .timeline
            }

        } else {
            outgoingTransition = .none
            incomingTransition = .none
        }

        let currentContext = ListenModeDebugStorage.shared.contexts.first
        switch content {
        case .numerical:
            let numericContentController = NumericCategoryContentViewController()
            numericContentController.$lastUtterance
                .sink { [weak self] utterance in
                    self?.lastUtterance = utterance
                }
                .store(in: &numericContentController.disposables)
            let wrapperViewController = ListeningResponseFeedbackViewController(viewController: numericContentController, loggingContext: currentContext, choices: numericContentController.contentItems())
            setContentViewController(wrapperViewController, outgoingTransition: outgoingTransition, incomingTransition: incomingTransition)

        case .choices(let choices):
            let reponseContentController = ListeningResponseContentViewController()
            reponseContentController.content = choices
            reponseContentController.synthesizedSpeechQueue = synthesizedSpeechQueue
            reponseContentController.$lastUtterance
                .sink { [weak self] utterance in
                    self?.lastUtterance = utterance
                }
                .store(in: &reponseContentController.disposables)
            let wrapperViewController = ListeningResponseFeedbackViewController(viewController: reponseContentController, loggingContext: currentContext, choices: choices)
            setContentViewController(wrapperViewController, outgoingTransition: outgoingTransition, incomingTransition: incomingTransition)

        case .empty(let state, let action):
            switch state {
            case .listenModeFreeResponse:
                let viewController = ListeningResponseFeedbackViewController(viewController: ListeningResponseEmptyStateViewController(state: state, action: action), loggingContext: currentContext)
                setContentViewController(viewController, outgoingTransition: outgoingTransition, incomingTransition: incomingTransition)
            default:
                let viewController = ListeningResponseEmptyStateViewController(state: state, action: action)
                setContentViewController(viewController, outgoingTransition: outgoingTransition, incomingTransition: incomingTransition)
            }
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
            .debounce(for: .seconds(0.08), scheduler: DispatchQueue.main)
            .removeDuplicates()
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

        ListenModeDebugStorage.shared.append(result.context)

        guard let responses = result.responses, !responses.isEmpty else {
            content = .empty(.listenModeFreeResponse)
            return
        }

        if case .numerical = result.classification {
            content = .numerical
        } else {
            content = .choices(responses)
        }
    }

    private func setContentViewController(_ viewController: UIViewController?, outgoingTransition: TransitionStyle = .none, incomingTransition: TransitionStyle = .none) {

        transitionAnimators.removeAll()

        let layoutGuide = self.contentViewLayoutGuide
        if let viewController = viewController {
            installViewController(viewController, in: layoutGuide)
        }

        let previousContentViewController = self.contentViewController
        self.contentViewController = viewController

        let entranceAnimator: TransitionAnimator? = {

            var animator: TransitionAnimator? = .none

            switch incomingTransition {
            case .none:
                return nil
            case .inline:
                animator = inlineTransitionAnimator(for: viewController, in: layoutGuide.layoutFrame, isEntering: true)
            case .timeline:
                animator = timelineTransitionAnimator(for: viewController, in: layoutGuide.layoutFrame, isEntering: true)
            }

            if [incomingTransition, outgoingTransition].contains(.inline) {
                animator = animator?.withDelay(0.33)
            }

            return animator
        }()

        let exitAnimator: TransitionAnimator? = {
            func didFinish(_ completed: Bool) {
                previousContentViewController?.removeFromParent()
                previousContentViewController?.view.removeFromSuperview()
            }
            var animator: TransitionAnimator?
            switch outgoingTransition {
            case .none:
                didFinish(true)
                animator = nil
            case .inline:
                animator = inlineTransitionAnimator(for: previousContentViewController, in: layoutGuide.layoutFrame, isEntering: false)
            case .timeline:
                animator = timelineTransitionAnimator(for: previousContentViewController, in: layoutGuide.layoutFrame, isEntering: false)
            }

            animator?.propertyAnimator.addCompletion { position in
                didFinish(position == .end)
            }
            return animator
        }()

        [entranceAnimator, exitAnimator].compacted().forEach { [weak self] animator in
            animator.preflightActions()
            transitionAnimators.insert(animator.propertyAnimator)
            animator.propertyAnimator.addCompletion { _ in
                self?.transitionAnimators.remove(animator.propertyAnimator)
            }
            animator.propertyAnimator.startAnimation(afterDelay: animator.delay)
        }
    }

    private func timelineTransitionAnimator(for viewController: UIViewController?, in rect: CGRect, isEntering: Bool) -> TransitionAnimator? {

        guard let viewController = viewController else { return nil }

        let exitTransform = CGAffineTransform.identity
            .translatedBy(x: 0, y: -rect.height)

        let neutralTransform = CGAffineTransform.identity
        let entranceTransform = CGAffineTransform.identity
            .scaledBy(x: 0.8, y: 0.8)
            .translatedBy(x: 0, y: rect.height)

        let neutralAlpha: CGFloat = 1
        let exitAlpha: CGFloat = .zero
        let entranceAlpha: CGFloat = .zero
        let duration: TimeInterval = 1.5
        let dampingRatio: CGFloat = 0.8

        func prepare() {
            if isEntering {
                viewController.view.transform = entranceTransform
                viewController.view.alpha = entranceAlpha
            }
        }

        func actions() {
            if isEntering {
                viewController.view.transform = neutralTransform
                viewController.view.alpha = neutralAlpha
            } else {
                viewController.view.transform = exitTransform
                viewController.view.alpha = exitAlpha
            }
        }

        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio, animations: actions)
        return TransitionAnimator(propertyAnimator: animator, preflightActions: prepare)
    }

    private func inlineTransitionAnimator(for viewController: UIViewController?, in rect: CGRect, isEntering: Bool) -> TransitionAnimator? {

        guard let viewController = viewController else { return nil }

        let exitTransform: CGAffineTransform = .identity
        let neutralTransform: CGAffineTransform = .identity
        let entranceTransform: CGAffineTransform = .identity

        let neutralAlpha: CGFloat = 1
        let exitAlpha: CGFloat = .zero
        let entranceAlpha: CGFloat = .zero
        let duration: TimeInterval = 0.33
        let curve: UIView.AnimationCurve = isEntering ? .easeIn : .easeOut

        func prepare() {
            if isEntering {
                viewController.view.transform = entranceTransform
                viewController.view.alpha = entranceAlpha
            }
        }

        func actions() {
            if isEntering {
                viewController.view.transform = neutralTransform
                viewController.view.alpha = neutralAlpha
            } else {
                viewController.view.transform = exitTransform
                viewController.view.alpha = exitAlpha
            }
        }

        let animator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: actions)

        return TransitionAnimator(propertyAnimator: animator, preflightActions: prepare)
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
