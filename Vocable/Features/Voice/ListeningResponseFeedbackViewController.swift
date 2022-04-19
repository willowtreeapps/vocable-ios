//
//  ListeningResponseFeedbackViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import UIKit

final class ListeningResponseFeedbackViewController: UIViewController {

    // MARK: Properties

    private lazy var feedbackStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [submitFeedbackView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private let viewController: UIViewController
    private let transcription: String

    private var contentDisposables = Set<AnyCancellable>()

    private let submitFeedbackView = ListeningFeedbackSubmitView()
    private let successFeedbackView = ListeningFeedbackSuccessView()

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

    // MARK: Initializers

    init(viewController: UIViewController, transcription: String) {
        self.viewController = viewController
        self.transcription = transcription
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupResponseController()
        setupFeedbackView()
    }

    private func setupResponseController() {
        addChild(viewController)

        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        let viewControllerConstraints = [viewController.view.topAnchor.constraint(equalTo: contentViewLayoutGuide.topAnchor),
                                     viewController.view.leadingAnchor.constraint(equalTo: contentViewLayoutGuide.leadingAnchor),
                                     viewController.view.trailingAnchor.constraint(equalTo: contentViewLayoutGuide.trailingAnchor)]
        NSLayoutConstraint.activate(viewControllerConstraints)

        viewController.didMove(toParent: self)
    }

    private func setupFeedbackView() {
        submitFeedbackView.submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .primaryActionTriggered)
        submitFeedbackView.infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .primaryActionTriggered)

        view.addSubview(feedbackStackView)
        feedbackStackView.translatesAutoresizingMaskIntoConstraints = false
        let feedbackConstraints = [feedbackStackView.topAnchor.constraint(equalTo: viewController.view.bottomAnchor),
                                   feedbackStackView.leadingAnchor.constraint(equalTo: contentViewLayoutGuide.leadingAnchor),
                                   feedbackStackView.trailingAnchor.constraint(equalTo: contentViewLayoutGuide.trailingAnchor),
                                   feedbackStackView.bottomAnchor.constraint(equalTo: contentViewLayoutGuide.bottomAnchor)]
        NSLayoutConstraint.activate(feedbackConstraints)
    }

    @objc private func didTapSubmitButton() {
        submitFeedback()
        UIView.transition(with: feedbackStackView, duration: 0.25, options: .transitionCrossDissolve) {
            self.feedbackStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.feedbackStackView.addArrangedSubview(self.successFeedbackView)
        }
    }

    @objc private func didTapInfoButton() {
        let alertViewController = GazeableAlertViewController(alertTitle: "Submitting text: \(transcription)")

        alertViewController.addAction(GazeableAlertAction(title: "OK"))
        alertViewController.addAction(GazeableAlertAction(title: "Submit", style: .bold, handler: { [weak self] in
            self?.submitFeedback()
        }))
        present(alertViewController, animated: true)
    }

    private func submitFeedback() {
        // TODO: submit feedback to mixpanel
    }

}
