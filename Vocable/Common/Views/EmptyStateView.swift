//
//  EmptyStateView.swift
//  Vocable
//
//  Created by Chris Stroud on 4/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class EmptyStateView: UIView {

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

    private lazy var stackView = UIStackView(arrangedSubviews: [self.imageView, self.label])

    init(text: String, image: UIImage? = nil) {
        super.init(frame: .zero)
        self.text = text
        self.image = image
        commonInit()
    }

    init(attributedText: NSAttributedString) {
        super.init(frame: .zero)
        self.text = nil
        self.image = nil
        self.attributedText = attributedText
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        layoutMargins = .zero
        backgroundColor = .collectionViewBackgroundColor

        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center

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

        imageView.tintColor = .defaultTextColor

        label.textColor = .defaultTextColor
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.numberOfLines = 0

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: readableContentGuide.widthAnchor)
        ])
    }
}
