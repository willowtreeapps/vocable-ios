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
        updateForCurrentTraitCollection()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForCurrentTraitCollection()
    }

    private func updateForCurrentTraitCollection() {
        let hasCompactSize = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass]
            .contains(.compact)

        contentEdgeInsets = hasCompactSize ?
            .vertical(8) + .horizontal(48) :
            .uniform(32)
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

        backgroundColor = .collectionViewBackgroundColor

        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center

        if action != nil {
            if let title = button.title(for: .normal) {
                let attributed = NSAttributedString(string: title,
                                                    attributes: [.foregroundColor: UIColor.defaultTextColor])
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
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.widthAnchor.constraint(lessThanOrEqualTo: readableContentGuide.widthAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.heightAnchor)
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
        let hasCompactSize = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass]
            .contains(.compact)

        let font: UIFont = hasCompactSize ?
            .systemFont(ofSize: 22, weight: .bold) :
            .systemFont(ofSize: 28, weight: .bold)

        titleLabel.font = font

        if let attributedButtonTitle = button.attributedTitle(for: .normal) {
            let updatedButtonTitle = NSMutableAttributedString(attributedString: attributedButtonTitle)
            updatedButtonTitle.addAttribute(.font, value: font, range: updatedButtonTitle.string.fullNSRange)
            button.setAttributedTitle(updatedButtonTitle, for: .normal)
        }

    }

    @objc private func handleButton(_ sender: GazeableButton) {
        action?()
    }

    private func updateStackView() {
        imageView.isHidden = imageView.image == nil
        descriptionLabel.isHidden = descriptionLabel.text == nil && descriptionLabel.attributedText == nil
    }
}
