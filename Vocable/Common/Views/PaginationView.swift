//
//  PaginationView.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

private class PaginationViewGazeableButton: GazeableButton {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            return CGSize(width: 56, height: 48)
        }
        return CGSize(width: 104, height: 94)
    }
}

@IBDesignable
final class PaginationView: UIView {

    let textLabel = UILabel(frame: .zero)
    private let stackView = UIStackView(frame: .zero)

    let previousPageButton: GazeableButton = PaginationViewGazeableButton(frame: .zero)
    let nextPageButton: GazeableButton = PaginationViewGazeableButton(frame: .zero)

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {

        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)

        backgroundColor = .collectionViewBackgroundColor
        isOpaque = true
        insetsLayoutMarginsFromSafeArea = false

        textLabel.textColor = .defaultTextColor
        textLabel.textAlignment = .center
        textLabel.backgroundColor = backgroundColor
        textLabel.isOpaque = true
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.8
        textLabel.numberOfLines = 2
        textLabel.setContentCompressionResistancePriority(.init(999), for: .horizontal)

        nextPageButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextPageButton.tintColor = .defaultTextColor
        nextPageButton.accessibilityIdentifier = "bottomPagination.right_chevron"
        nextPageButton.backgroundColor = backgroundColor
        nextPageButton.isOpaque = true
        nextPageButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        previousPageButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousPageButton.tintColor = .defaultTextColor
        previousPageButton.accessibilityIdentifier = "bottomPagination.left_chevron"
        previousPageButton.backgroundColor = backgroundColor
        previousPageButton.isOpaque = true
        previousPageButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        stackView.axis = .horizontal
        stackView.backgroundColor = .collectionViewBackgroundColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.isOpaque = true
        
        stackView.addArrangedSubview(previousPageButton)
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(nextPageButton)

        updateForCurrentTraitCollection()
    }
    
    func setPaginationButtonsEnabled(_ isEnabled: Bool) {
        previousPageButton.isEnabled = isEnabled
        nextPageButton.isEnabled = isEnabled
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForCurrentTraitCollection()
    }

    private func updateForCurrentTraitCollection() {
        if sizeClass.contains(any: .compact) {
            stackView.spacing = 24
            textLabel.font = .systemFont(ofSize: 22, weight: .bold)
            return
        }
        stackView.spacing = 42
        textLabel.font = .systemFont(ofSize: 28, weight: .bold)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        // This is placeholder text for IBDesignable  so localization is not necessary.
        textLabel.text = "Page 1 of 3"
    }
    
}
