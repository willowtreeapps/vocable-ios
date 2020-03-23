//
//  GazeableAlertViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazableAlertAction: NSObject {

    let title: String
    let handler: (() -> Void)?
    fileprivate var defaultCompletion: (() -> Void)?

    init(title: String, handler: (() -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }

    @objc fileprivate func performActions() {
        handler?()
        defaultCompletion?()
    }

}

private final class DividerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        self.backgroundColor = .grayDivider
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 1, height: 1)
    }

}

private final class GazeableAlertView: BorderedView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.roundedCorners = .allCorners
        self.cornerRadius = 14
        self.fillColor = .alertBackgroundColor
        self.setContentHuggingPriority(.required, for: .horizontal)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            return CGSize(width: 695 / 2, height: UIView.noIntrinsicMetric)
        }
        return CGSize(width: 695, height: UIView.noIntrinsicMetric)
    }

}

private final class GazeableAlertButton: GazeableButton {

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {
        self.fillColor = .alertBackgroundColor
        self.selectionFillColor = .primaryColor
        self.setTitleColor(.white, for: .selected)
        self.setTitleColor(.black, for: .normal)
        self.backgroundView.cornerRadius = 14

        updateForCurrentTraitCollection()
    }

    private func updateForCurrentTraitCollection() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        contentEdgeInsets = .init(top: 24, left: 24, bottom: 24, right: 24)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateForCurrentTraitCollection()
    }

}

final class GazeableAlertViewController: UIViewController {

    private lazy var alertView: GazeableAlertView = {
        let view = GazeableAlertView()
        return view
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private lazy var titleContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButtonStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()

    private var actions = [GazableAlertAction]() {
        didSet {
            updateButtonLayout()
        }
    }

    init(alertTitle: String) {
        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .overFullScreen
        self.titleLabel.text = alertTitle
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        setupViews()
        updateContentForCurrentTraitCollection()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateContentForCurrentTraitCollection()
    }

    private func updateContentForCurrentTraitCollection() {
        if traitCollection.horizontalSizeClass == .regular {
            titleLabel.font = .systemFont(ofSize: 34)
            titleContainerView.layoutMargins = UIEdgeInsets(top: 40, left: 50, bottom: 40, right: 50)
        } else {
            titleLabel.font = .systemFont(ofSize: 17)
            titleContainerView.layoutMargins = UIEdgeInsets(top: 36, left: 12, bottom: 36, right: 12)
        }
    }

    func addAction(_ action: GazableAlertAction) {
        action.defaultCompletion = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true)
        }

        actions.append(action)
    }

    private func setupViews() {

        let alertView = GazeableAlertView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)

        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        alertView.addSubview(containerStackView)
        containerStackView.addArrangedSubview(titleContainerView)

        let dividerView = DividerView(frame: .zero)
        containerStackView.addArrangedSubview(dividerView)
        containerStackView.addArrangedSubview(actionButtonStackView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            alertView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: alertView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    private func updateButtonLayout() {

        for view in actionButtonStackView.arrangedSubviews {
            actionButtonStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        var firstButton: GazeableButton?

        actions.forEach { action in
            let button = GazeableAlertButton(frame: .zero)
            button.setTitle(action.title, for: .normal)
            button.backgroundView.cornerRadius = alertView.cornerRadius
            button.addTarget(action, action: #selector(GazableAlertAction.performActions), for: .primaryActionTriggered)

            if actionButtonStackView.arrangedSubviews.isEmpty {
                firstButton = button
                actionButtonStackView.addArrangedSubview(button)
            } else {
                let separator = DividerView()
                actionButtonStackView.addArrangedSubview(separator)
                actionButtonStackView.addArrangedSubview(button)

                if actionButtonStackView.axis == .horizontal {
                    button.widthAnchor.constraint(equalTo: firstButton!.widthAnchor).isActive = true
                } else {
                    button.heightAnchor.constraint(equalTo: firstButton!.heightAnchor).isActive = true
                }
            }

            if actions.count > 2 {
                actionButtonStackView.axis = .vertical
            } else {
                actionButtonStackView.axis = .horizontal
            }
        }

        let buttons: [GazeableAlertButton] = actionButtonStackView.arrangedSubviews.compactMap {
            if let button = $0 as? GazeableAlertButton {
                button.backgroundView.roundedCorners = []
                return button
            }
            return nil
        }

        let firstAlertButton = buttons.first
        let lastAlertButton = buttons.last

        if actions.count < 3 {
            firstAlertButton?.backgroundView.roundedCorners.insert(.bottomLeft)
            lastAlertButton?.backgroundView.roundedCorners.insert(.bottomRight)
        } else {
            lastAlertButton?.backgroundView.roundedCorners.insert([.bottomLeft, .bottomRight])
        }
    }

}
