//
//  EmptyStateView.swift
//  Vocable
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

    typealias ButtonConfiguration = (title: String, action: () -> Void)

    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue

            if newValue != nil {
                stackView.insertArrangedSubview(imageView, at: 0)
            } else {
                stackView.removeArrangedSubview(imageView)
                imageView.removeFromSuperview()
            }
        }
    }

    var text: String? {
        get {
            label.text
        }
        set {
            label.text = newValue
        }
    }

    var attributedText: NSAttributedString? {
        get {
            label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }

    private let imageView = UIImageView(frame: .zero)
    private let label = UILabel(frame: .zero)
    private let button = EmptyStateButton(frame: .zero)
    private let action: ButtonConfiguration?

    private lazy var stackView = UIStackView(arrangedSubviews: [self.imageView, self.label])

    init(text: String, image: UIImage? = nil, action: ButtonConfiguration? = nil) {
        self.action = action
        super.init(frame: .zero)
        self.text = text
        self.image = image
        commonInit()
    }

    init(attributedText: NSAttributedString, action: ButtonConfiguration? = nil) {
        self.action = action
        super.init(frame: .zero)
        self.text = nil
        self.image = nil
        self.attributedText = attributedText
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

        if let action = action {
            let font = UIFont.boldSystemFont(ofSize: 18)
            let attributed = NSAttributedString(string: action.title,
                                                attributes: [.font: font, .foregroundColor: UIColor.defaultTextColor])
            button.setAttributedTitle(attributed, for: .normal)
            button.addTarget(self,
                             action: #selector(handleButton(_:)),
                             for: .primaryActionTriggered)
            stackView.addArrangedSubview(button)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            stackView.leftAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        let color = UIColor.defaultTextColor
        imageView.tintColor = color

        label.textColor = color
        label.textAlignment = .center
        label.numberOfLines = 0

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor)
        ])

        updateContentForCurrentTraitCollection()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContentForCurrentTraitCollection()
    }

    private func updateContentForCurrentTraitCollection() {

        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            label.font = .boldSystemFont(ofSize: 28)
        } else {
            label.font = .boldSystemFont(ofSize: 20)
        }
    }

    @objc private func handleButton(_ sender: GazeableButton) {
        action?.action()
    }
}
