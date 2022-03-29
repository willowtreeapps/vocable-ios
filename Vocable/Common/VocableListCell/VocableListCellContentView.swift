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
        let stackView = UIStackView(arrangedSubviews: [accessoryButtonStackView, primaryLabelButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private lazy var accessoryButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    private lazy var primaryLabelButton: VocableListCellPrimaryButton = {
        let button = VocableListCellPrimaryButton()
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = .init(uniform: 16)
        return button
    }()

    private var buttonWidthConstraints = [NSLayoutConstraint]()

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

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).withPriority(999),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).withPriority(999),
            primaryLabelButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).withPriority(.defaultHigh)
        ])

        configure(with: configuration)
    }

    private func updateActionConfiguration(to configuration: VocableListContentConfiguration.ActionsConfiguration?) {

        let desiredAccessoryIndex: Array<UIView>.Index
        switch configuration?.position {
        case .leading, .none:

            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fill
            accessoryButtonStackView.alignment = .fill
            accessoryButtonStackView.distribution = .fillEqually

            desiredAccessoryIndex = stackView.arrangedSubviews.indices.lowerBound

        case .bottom:

            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.distribution = .fillEqually
            accessoryButtonStackView.alignment = .top
            accessoryButtonStackView.distribution = .fillEqually

            desiredAccessoryIndex = stackView.arrangedSubviews.indices.upperBound
        }

        let currentIndex = stackView.arrangedSubviews.firstIndex(of: accessoryButtonStackView)
        if currentIndex != desiredAccessoryIndex {
            accessoryButtonStackView.removeFromSuperview()
            if stackView.arrangedSubviews.indices.contains(desiredAccessoryIndex) {
                stackView.insertArrangedSubview(accessoryButtonStackView, at: desiredAccessoryIndex)
            } else {
                stackView.addArrangedSubview(accessoryButtonStackView)
            }
        }

        NSLayoutConstraint.deactivate(buttonWidthConstraints)
        buttonWidthConstraints.removeAll()

        let widthDimension = configuration?.size.widthDimension ?? .fractionalHeight(1.0)
        let constraintsToActivate = accessoryButtonStackView.arrangedSubviews.map { view -> NSLayoutConstraint in
            buttonWidthConstraint(for: view, widthDimension: widthDimension)
        }

        NSLayoutConstraint.activate(constraintsToActivate)
        buttonWidthConstraints.append(contentsOf: constraintsToActivate)
    }

    private func buttonWidthConstraint(for view: UIView, widthDimension: VocableListContentConfiguration.ActionsConfiguration.LayoutSize.Dimension) -> NSLayoutConstraint {
        switch widthDimension {
        case .absolute(let value):
            return view.widthAnchor.constraint(equalToConstant: value)
        case .fractionalHeight(let value):
            return view.widthAnchor.constraint(equalTo: accessoryButtonStackView.heightAnchor, multiplier: value)
        case .fractionalWidth(let value):
            return view.widthAnchor.constraint(equalTo: accessoryButtonStackView.widthAnchor, multiplier: value)
        }
    }

    private func configure(with configuration: UIContentConfiguration) {
        let configuration = configuration as? VocableListContentConfiguration

        updateActionConfiguration(to: configuration?.actionsConfiguration)
        updateLeadingActionAccessoryButtons(with: configuration)
        updatePrimaryLabelButton(with: configuration)
    }

    private func updatePrimaryLabelButton(with configuration: VocableListContentConfiguration?) {
        primaryLabelButton.contentHorizontalAlignment = configuration?.primaryContentHorizontalAlignment ?? .center
        primaryLabelButton.setTrailingAccessory(configuration?.accessory)
        primaryLabelButton.setAttributedTitle(configuration?.attributedTitle, for: .normal)
        primaryLabelButton.accessibilityLabel = configuration?.accessibilityLabel
        primaryLabelButton.accessibilityIdentifier = configuration?.accessibilityIdentifier
        primaryLabelButton.addTarget(self, action: #selector(handlePrimaryActionSelection(_:)), for: .primaryActionTriggered)

        if let backgroundColor = configuration?.primaryBackgroundColor {
            primaryLabelButton.setFillColor(backgroundColor, for: .normal)
        }
    }

    private func updateLeadingActionAccessoryButtons(with configuration: VocableListContentConfiguration?) {

        let actions = configuration?.actions ?? []

        // Ensure the minimum number of action buttons are present
        let numberOfButtonsNeeded = max(actions.count - accessoryButtonStackView.arrangedSubviews.count, .zero)
        (.zero ..< numberOfButtonsNeeded).forEach { _ in
            guard let configuration = configuration else { return }
            insertAccessoryButton(configuration: configuration.actionsConfiguration)
        }

        // Update existing buttons to match new states
        let arrangedButtons = accessoryButtonStackView.arrangedSubviews.compactMap { $0 as? GazeableButton }
        zip(actions, arrangedButtons).forEach { (action, button) in
            button.isHidden = false
            button.setImage(action.image, for: .normal)
            button.isEnabled = action.isEnabled
            button.accessibilityLabel = action.accessibilityLabel
            button.accessibilityIdentifier = action.accessibilityIdentifier
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

    private func insertAccessoryButton(configuration: VocableListContentConfiguration.ActionsConfiguration) {
        let button = GazeableButton()
        accessoryButtonStackView.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            buttonWidthConstraint(for: button, widthDimension: configuration.size.widthDimension),
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
