//
//  EmptyStateView.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 4/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

private class EmptyStateButton: GazeableButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        contentEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    }
}

protocol EmptyStateRepresentable {
    var title: String { get }
    var description: String? { get }
    var buttonTitle: String? { get }
    var image: UIImage? { get }
}

enum EmptyStateType: EmptyStateRepresentable {

    case recents
    case phraseCollection

    var title: String {
        switch self {
        case.recents:
            return NSLocalizedString("recents_empty_state.header.title", comment: "Recents empty state title")
        case .phraseCollection:
            return NSLocalizedString("empty_state.header.title", comment: "Empty state title")
        }
    }

    var description: String? {
        switch self {
        case .recents:
            return NSLocalizedString("recents_empty_state.body.title", comment: "Recents empty state description")
        default:
            return nil
        }
    }

    var buttonTitle: String? {
        switch self {
        case .recents:
            return nil
        default:
            return NSLocalizedString("empty_state.button.title", comment: "Empty state Add Phrase button title")
        }
    }

    var image: UIImage? {
        switch self {
        case .recents:
            return UIImage(named: "recents")
        default:
            return nil
        }
    }
}

final class EmptyStateView: UIView {

    typealias ButtonConfiguration = (() -> Void)?

    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
            updateStackView()
        }
    }

    var titleAttributedText: NSAttributedString? {
        get {
            titleLabel.attributedText
        }
        set {
            titleLabel.attributedText = newValue
        }
    }

    var descriptionAttributedText: NSAttributedString? {
        get {
            descriptionLabel.attributedText
        }
        set {
            descriptionLabel.attributedText = newValue
            updateStackView()
        }
    }

    private let imageView = UIImageView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let descriptionLabel = UILabel(frame: .zero)
    private let button = EmptyStateButton(frame: .zero)
    private var action: ButtonConfiguration

    private lazy var stackView = UIStackView(arrangedSubviews: [self.imageView, self.titleLabel, self.descriptionLabel])

    init<T: EmptyStateRepresentable>(type: T, action: ButtonConfiguration = nil) {
        self.action = action
        super.init(frame: .zero)

        imageView.image = type.image
        let attributedTitle = NSAttributedString(string: type.title, attributes: [.font: UIFont.boldSystemFont(ofSize: 24), .foregroundColor: UIColor.defaultTextColor])
        titleAttributedText = attributedTitle

        if let description = type.description {
            let attributedDescription = NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            descriptionAttributedText = attributedDescription
        } else {
            descriptionAttributedText = nil
        }
        button.setTitle(type.buttonTitle, for: .normal)

        commonInit()
    }

    required init?(coder: NSCoder) {
        self.action = nil
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        preservesSuperviewLayoutMargins = true

        backgroundColor = .collectionViewBackgroundColor

        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center

        if action != nil {
            let font = UIFont.boldSystemFont(ofSize: 18)
            if let title = button.title(for: .normal) {
                let attributed = NSAttributedString(string: title,
                                                    attributes: [.font: font, .foregroundColor: UIColor.defaultTextColor])
                button.setAttributedTitle(attributed, for: .normal)
            }
            button.addTarget(self,
                             action: #selector(handleButton(_:)),
                             for: .primaryActionTriggered)
            stackView.addArrangedSubview(button)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.widthAnchor.constraint(lessThanOrEqualTo: readableContentGuide.widthAnchor)
        ])

        let color = UIColor.defaultTextColor
        imageView.tintColor = color

        titleLabel.textColor = color
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        descriptionLabel.numberOfLines = 0

        updateContentForCurrentTraitCollection()
        updateStackView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContentForCurrentTraitCollection()
    }

    private func updateContentForCurrentTraitCollection() {

        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            titleLabel.font = .boldSystemFont(ofSize: 28)
        } else {
            titleLabel.font = .boldSystemFont(ofSize: 20)
        }
    }

    @objc private func handleButton(_ sender: GazeableButton) {
        if let action = action {
            action()
        }
    }

    private func updateStackView() {
        if imageView.image != nil {
            stackView.insertArrangedSubview(imageView, at: 0)
        } else {
            stackView.removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }

        if descriptionLabel.text != nil {
            stackView.insertSubview(descriptionLabel, belowSubview: titleLabel)
        } else {
            stackView.removeArrangedSubview(descriptionLabel)
            descriptionLabel.removeFromSuperview()
        }

        if descriptionLabel.attributedText != nil {
            stackView.insertSubview(descriptionLabel, belowSubview: titleLabel)
        } else {
            stackView.removeArrangedSubview(descriptionLabel)
            descriptionLabel.removeFromSuperview()
        }
    }
}
