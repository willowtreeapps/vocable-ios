//
//  ListeningFeedbackSubmitView.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

final class ListeningFeedbackSubmitView: UIView {

    // MARK: Properties

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [hintLabel, submitButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    let hintLabel = UILabel()
    let submitButton = GazeableButton()

    // MARK: Initializers

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let font: UIFont = sizeClass == .hRegular_vRegular
                           ? .systemFont(ofSize: 26, weight: .bold)
                           : .systemFont(ofSize: 15, weight: .bold)

        let hintText = NSLocalizedString("listening_mode.feedback.hint.text", comment: "Submit feedback hint text")
        hintLabel.text = hintText
        hintLabel.font = font
        hintLabel.textColor = .defaultTextColor

        let buttonTitle = NSLocalizedString("listening_mode.feedback.submit.title", comment: "Submit feedback button title")
        submitButton.setTitle(buttonTitle, for: .normal)
        submitButton.titleLabel?.font = font
//        submitButton.contentEdgeInsets = .uniform(16)
        submitButton.isUserInteractionEnabled = true
        submitButton.titleLabel?.textColor = .defaultTextColor

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                                     stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }
}
