//
//  ListeningFeedbackSubmitView.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

final class ListeningFeedbackSubmitView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [submitButton, infoButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    let submitButton = GazeableButton()
    let infoButton = GazeableButton()

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
                           ? .systemFont(ofSize: 34, weight: .bold)
                           : .systemFont(ofSize: 22, weight: .bold)
        // TODO: localize and finalize copy
        submitButton.setTitle("Submit Review", for: .normal)
        submitButton.titleLabel?.font = font
        submitButton.contentEdgeInsets = .uniform(16)
        submitButton.isUserInteractionEnabled = true

        infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        infoButton.isUserInteractionEnabled = true

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [stackView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                           stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                           stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
}
