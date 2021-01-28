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

class EmptyStateView: UIView {

    enum EmptyStateType {

        case recents
        case phraseCollection
        case listeningResponse
        case speechPermissionDenied
        case speechPermissionUndetermined
        case microphonePermissionDenied
        case microphonePermissionUndetermined

        var title: NSAttributedString {
            switch self {
            case.recents:
                let title = NSLocalizedString("recents_empty_state.header.title", comment: "Recents empty state title")
                return NSAttributedString(string: title, attributes: [.font: UIFont.boldSystemFont(ofSize: 24), .foregroundColor: UIColor.defaultTextColor])
            case .phraseCollection:
                let title = NSLocalizedString("empty_state.header.title", comment: "Empty state title")
                return NSAttributedString(string: title)
            case .microphonePermissionUndetermined, .microphonePermissionDenied:
                #warning("Needs localization")
                let title = "Microphone Access"
                return NSAttributedString(string: title)
            case .speechPermissionDenied, .speechPermissionUndetermined:
                #warning("Needs localization")
                let title = "Speech Recognition"
                return NSAttributedString(string: title)
            case .listeningResponse:
                #warning("Needs localization")
                let title = "Listening..."
                return NSAttributedString(string: title)
            }
        }

        var description: NSAttributedString? {
            switch self {
            case .recents:
                let description = NSLocalizedString("recents_empty_state.body.title", comment: "Recents empty state description")
                return NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            case .microphonePermissionUndetermined:
                #warning("Needs localization")
                let description = "Vocable needs microphone access to enable Listening Mode. The button below presents an iOS permission dialog that Vocable's head tracking cannot interract with."
                return NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            case .microphonePermissionDenied:
                #warning("Needs localization")
                let description = "Vocable needs to use the microphone to enable Listening Mode. Please enable microphone access in the system Settings app.\n\nYou can also disable Listening Mode to hide this category in Vocable's settings."
                return NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            case .speechPermissionUndetermined:
                #warning("Needs localization")
                let description = "Vocable needs to request speech permissions to enable Listening Mode. This will present an iOS permission dialog that Vocable's head tracking cannot interract with."
                return NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            case .speechPermissionDenied:
                #warning("Needs localization")
                let description = "Vocable needs speech recognition to enable Listening Mode. Please enable speech recognition in the system Settings app.\n\nYou can also disable Listening Mode to hide this category in Vocable's settings."
                return NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            case .listeningResponse:
                #warning("Needs localization")
                let description = "When in listening mode, if someone starts speaking, Vocable will try to show quick responses."
                return NSAttributedString(string: description, attributes: [.foregroundColor: UIColor.defaultTextColor])
            default:
                return nil
            }
        }

        var buttonTitle: String? {
            switch self {
            case .recents:
                return nil
            case .microphonePermissionUndetermined, .speechPermissionUndetermined:
                #warning("Needs localization")
                return "Grant Access"
            case .microphonePermissionDenied, .speechPermissionDenied:
                #warning("Needs localization")
                return "Open Settings"
            default:
                return NSLocalizedString("empty_state.button.title", comment: "Empty state Add Phrase button title")
            }
        }
    }

    typealias ButtonConfiguration = (() -> Void)

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
    private var action: ButtonConfiguration?

    private lazy var stackView = UIStackView(arrangedSubviews: [self.imageView, self.titleLabel, self.descriptionLabel])

    init(type: EmptyStateType, action: ButtonConfiguration? = nil) {
        self.action = action
        super.init(frame: .zero)

        switch type {
        case .recents:
            imageView.image = UIImage(named: "recents")
            fallthrough
        default:
            titleAttributedText = type.title
            descriptionAttributedText = type.description
            button.setTitle(type.buttonTitle, for: .normal)
        }

        commonInit()
    }

    required init?(coder: NSCoder) {
        self.action = nil
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        layoutMargins = .zero

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
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        let color = UIColor.defaultTextColor
        imageView.tintColor = color

        titleLabel.textColor = color
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor)
        ])

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
