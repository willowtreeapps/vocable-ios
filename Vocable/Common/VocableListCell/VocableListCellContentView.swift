//
//  VocableListCellContentView.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//
import UIKit

final class VocableListCellContentView: UIView, UIContentView {

    // MARK: - Properties

    var configuration: UIContentConfiguration {
        didSet {
            configure(with: configuration)
        }
    }

    // MARK: - Subviews

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private lazy var accessoryButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private lazy var primaryLabelButton: VocableListCellPrimaryButton = {
        let button = VocableListCellPrimaryButton()
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = .init(uniform: 16)
        return button
    }()

    // MARK: - Lifecycle

    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = nil

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        accessoryButtonStackView.isHidden = true
        stackView.addArrangedSubview(accessoryButtonStackView)

        stackView.addArrangedSubview(primaryLabelButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).withPriority(999),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).withPriority(999),
            accessoryButtonStackView.heightAnchor.constraint(equalTo: stackView.heightAnchor),
            primaryLabelButton.heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])

        configure(with: configuration)
    }

    private func configure(with configuration: UIContentConfiguration) {
        guard let configuration = configuration as? VocableListContentConfiguration else {
            updateLeadingActionAccessoryButtons(with: nil)
            updatePrimaryLabelButton(with: nil)
            return
        }

        updateLeadingActionAccessoryButtons(with: configuration)
        updatePrimaryLabelButton(with: configuration)
    }

    private func updatePrimaryLabelButton(with configuration: VocableListContentConfiguration?) {
        primaryLabelButton.setTrailingAccessory(configuration?.accessory)
        primaryLabelButton.setAttributedTitle(configuration?.attributedTitle, for: .normal)
        primaryLabelButton.addTarget(self, action: #selector(handlePrimaryActionSelection(_:)), for: .primaryActionTriggered)
    }

    private func updateLeadingActionAccessoryButtons(with configuration: VocableListContentConfiguration?) {

        let actions = configuration?.actions ?? []

        // Ensure the minimum number of action buttons are present
        let numberOfButtonsNeeded = max(actions.count - accessoryButtonStackView.arrangedSubviews.count, .zero)
        (.zero ..< numberOfButtonsNeeded).forEach { _ in
            insertAccessoryButton()
        }

        // Update existing buttons to match new states
        let arrangedButtons = accessoryButtonStackView.arrangedSubviews.compactMap { $0 as? GazeableButton }
        zip(actions, arrangedButtons).forEach { (action, button) in
            button.isHidden = false
            button.setImage(action.image, for: .normal)
            button.isEnabled = action.isEnabled
            
            // Using UIControlEvent to avoid having to de-duplicate UIAction invocations
            button.addTarget(self,
                             action: #selector(handleLeadingAccessoryActionSelection(_:)),
                             for: .primaryActionTriggered)
        }

        // Hide extraneous buttons, if present
        let numberOfButtonsToHide = min(arrangedButtons.count - actions.count, 0)
        let buttonsToHide = arrangedButtons.suffix(numberOfButtonsToHide)
        buttonsToHide.forEach { button in
            button.isHidden = true
        }

        // If there are no buttons to display, hide their stack view
        accessoryButtonStackView.isHidden = arrangedButtons.allSatisfy(\.isHidden)
    }

    private func insertAccessoryButton() {
        let button = GazeableButton()
        accessoryButtonStackView.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1),
            button.heightAnchor.constraint(equalTo: accessoryButtonStackView.heightAnchor)
        ])
    }

    // MARK: - Action Handlers

    @objc
    private func handlePrimaryActionSelection(_ sender: GazeableButton) {
        guard let configuration = configuration as? VocableListContentConfiguration else {
            return
        }
        configuration.primaryAction?()
    }

    @objc
    private func handleLeadingAccessoryActionSelection(_ sender: GazeableButton) {

        guard let buttonIndex = accessoryButtonStackView.arrangedSubviews.firstIndex(of: sender),
              let configuration = configuration as? VocableListContentConfiguration,
              let accessory = configuration.actions[safe: buttonIndex] else {
            return
        }

        accessory.action?()
    }
}
