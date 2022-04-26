//
//  ListeningResponseFeedbackViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import UIKit
import VocableListenCore

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
    private let loggingContext: VLLoggingContext?

    private var contentDisposables = Set<AnyCancellable>()

    private let submitFeedbackView = ListeningFeedbackSubmitView()
    private let successFeedbackView = ListeningFeedbackSuccessView()

    var feedbackViewHeightConstraint: NSLayoutConstraint?

    let contentViewControllerLayoutGuide = UILayoutGuide()
    let contentFeedbackLayoutGuide = UILayoutGuide()

    // MARK: Initializers

    init(viewController: UIViewController, loggingContext: VLLoggingContext?) {
        self.viewController = viewController
        self.loggingContext = loggingContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayoutGuides()
        setupResponseController()
        setupFeedbackView()
    }

    private func setupLayoutGuides() {
        view.addLayoutGuide(contentViewControllerLayoutGuide)
        view.addLayoutGuide(contentFeedbackLayoutGuide)

        NSLayoutConstraint.activate([
            contentViewControllerLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            contentViewControllerLayoutGuide.bottomAnchor.constraint(equalTo: contentFeedbackLayoutGuide.topAnchor),
            contentViewControllerLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewControllerLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentFeedbackLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentFeedbackLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentFeedbackLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupResponseController() {
        addChild(viewController)

        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([viewController.view.topAnchor.constraint(equalTo: contentViewControllerLayoutGuide.topAnchor),
                                     viewController.view.leadingAnchor.constraint(equalTo: contentViewControllerLayoutGuide.leadingAnchor),
                                     viewController.view.trailingAnchor.constraint(equalTo: contentViewControllerLayoutGuide.trailingAnchor),
                                     viewController.view.bottomAnchor.constraint(equalTo: contentViewControllerLayoutGuide.bottomAnchor)])

        viewController.didMove(toParent: self)
    }

    private func setupFeedbackView() {
        submitFeedbackView.submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .primaryActionTriggered)

        view.addSubview(feedbackStackView)
        feedbackStackView.translatesAutoresizingMaskIntoConstraints = false
        feedbackViewHeightConstraint = contentFeedbackLayoutGuide.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([feedbackStackView.topAnchor.constraint(equalTo: contentFeedbackLayoutGuide.topAnchor),
                                     feedbackStackView.leadingAnchor.constraint(equalTo: contentFeedbackLayoutGuide.leadingAnchor),
                                     feedbackStackView.trailingAnchor.constraint(equalTo: contentFeedbackLayoutGuide.trailingAnchor),
                                     feedbackStackView.bottomAnchor.constraint(equalTo: contentFeedbackLayoutGuide.bottomAnchor)])
    }

    // MARK: Actions

    @objc private func didTapSubmitButton() {
        submitFeedback()
    }

    // MARK: Private Helpers

    private func submitFeedback() {
        // TODO: submit feedback to mixpanel (use loggingContext)
        UIView.transition(with: feedbackStackView, duration: 0.35, options: .transitionCrossDissolve) { [self] in
            self.feedbackViewHeightConstraint?.constant = self.contentFeedbackLayoutGuide.layoutFrame.height
            self.feedbackViewHeightConstraint?.isActive = true
            self.feedbackStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.feedbackStackView.addArrangedSubview(self.successFeedbackView)
        }
    }
}
