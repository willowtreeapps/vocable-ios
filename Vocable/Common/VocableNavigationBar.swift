//
//  VocableNavigationBar.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

private class ContentView: UIView {

    var titleView: UIView? {
        didSet {
            updateVolatileView(new: titleView, old: oldValue)
        }
    }

    var leftButton: GazeableButton? {
        didSet {
            updateVolatileView(new: leftButton, old: oldValue)
        }
    }

//    var rightButton: GazeableButton? {
//        didSet {
//            updateVolatileView(new: rightButton, old: oldValue)
//        }
//    }

    var rightButtonsStackView: UIStackView? {
        didSet {
            // initialize

            updateVolatileView(new: rightButtonsStackView, old: oldValue)
        }
    }

    private var volatileConstraints = [NSLayoutConstraint]()

    private func updateVolatileView(new newValue: UIView?, old oldValue: UIView?) {
        guard oldValue != newValue else {
            return
        }
        if let newButton = newValue {
            newButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newButton)
        }
        oldValue?.removeFromSuperview()
        updateContentViews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContentViews()
    }

    private func updateContentViews() {

        layoutMargins = .zero
        leftButton?.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
//        rightButton?.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        // probably need to do something for the stackview
        setNeedsUpdateConstraints()
    }

    override var intrinsicContentSize: CGSize {
        if sizeClass.contains(any: .compact) {
            return CGSize(width: UIView.noIntrinsicMetric, height: 48)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: 96)
    }

    override func updateConstraints() {
        super.updateConstraints()

        layoutMargins = .zero

        let buttonSpacing: CGFloat
        let buttonSize: CGSize
        if sizeClass.contains(any: .compact) {
            buttonSpacing = 8
            buttonSize = CGSize(width: 64, height: intrinsicContentSize.height)
        } else {
            buttonSpacing = 16
            buttonSize = CGSize(width: 104, height: intrinsicContentSize.height)
        }

        NSLayoutConstraint.deactivate(volatileConstraints)

        var constraints = [NSLayoutConstraint]()

        let layoutMargins = layoutMarginsGuide

        // Title label
        if let titleView = titleView {
            titleView.setContentCompressionResistancePriority(.init(rawValue: 999), for: .horizontal)
            let titleCenterX = titleView.centerXAnchor.constraint(equalTo: centerXAnchor)
            titleCenterX.priority = .init(rawValue: 999)
            let titleCenterY = titleView.centerYAnchor.constraint(equalTo: layoutMargins.centerYAnchor)
            titleCenterY.priority = .init(rawValue: 999)

            constraints += [
                titleCenterX,
                titleCenterY,
                titleView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMargins.leadingAnchor),
                titleView.trailingAnchor.constraint(lessThanOrEqualTo: layoutMargins.trailingAnchor)
            ]
        }

        // Left button
        if let leftButton = leftButton {
            constraints += [
                leftButton.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
                leftButton.bottomAnchor.constraint(equalTo: layoutMargins.bottomAnchor),
                leftButton.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor),
                leftButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
                leftButton.heightAnchor.constraint(equalToConstant: buttonSize.height)
            ]

            if let titleView = titleView {
                constraints += [
                    titleView.leadingAnchor.constraint(greaterThanOrEqualTo: leftButton.trailingAnchor, constant: buttonSpacing)
                ]
            }
        }

        // Right button
//        if let rightButton = rightButton {
//            constraints += [
//                rightButton.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
//                rightButton.bottomAnchor.constraint(equalTo: layoutMargins.bottomAnchor),
//                rightButton.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor),
//                rightButton.widthAnchor.constraint(equalToConstant: buttonSize.width),
//                rightButton.heightAnchor.constraint(equalToConstant: buttonSize.height)
//            ]
//
//            if let titleView = titleView {
//                constraints += [
//                    rightButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleView.trailingAnchor, constant: buttonSpacing)
//                ]
//            }
//        }

        if let stackView = rightButtonsStackView {

            rightButtonsStackView?.spacing = 8
            rightButtonsStackView?.distribution = .fillEqually
            if let numberOfButtons = rightButtonsStackView?.arrangedSubviews.count {
                if numberOfButtons > 1 {
                    constraints += [stackView.widthAnchor.constraint(equalToConstant: (buttonSize.width * CGFloat(numberOfButtons)) + 8)]
                } else {
                    constraints += [stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: buttonSize.width)]
                }
            }

            constraints += [
                stackView.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: layoutMargins.bottomAnchor),
                stackView.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor),
                stackView.heightAnchor.constraint(equalToConstant: buttonSize.height)

            ]

            if let titleView = titleView {
                constraints += [
                    stackView.leadingAnchor.constraint(greaterThanOrEqualTo: titleView.trailingAnchor, constant: buttonSpacing)
                ]
            }
        }

        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints

        invalidateIntrinsicContentSize()
    }
}

class VocableNavigationBar: UIView {

    private var contentView = ContentView(frame: .zero)

    private var defaultTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.textColor = .defaultTextColor
        return label
    }()

    var title: String? {
        didSet {
            defaultTitleLabel.text = title
            if contentView.titleView == nil {
                contentView.titleView = defaultTitleLabel
            }
        }
    }

    var titleView: UIView? {
        set {
            if let newValue = newValue {
                contentView.titleView = newValue
            } else {
                contentView.titleView = defaultTitleLabel
            }
            updateSubviewAppearances()
        }
        get {
            if let titleView = contentView.titleView {
                if titleView == defaultTitleLabel {
                    return nil
                }
                return titleView
            }
            return nil
        }
    }

    var leftButton: GazeableButton? {
        get {
            contentView.leftButton
        }
        set {
            contentView.leftButton = newValue
            updateSubviewAppearances()
        }
    }

//    var rightButton: GazeableButton? {
//        get {
//            contentView.rightButton
//        }
//        set {
//            contentView.rightButton = newValue
//            updateSubviewAppearances()
//        }
//    }

    var rightButtonsStackView: UIStackView? {
        get {
            contentView.rightButtonsStackView
        }
        set {
            contentView.rightButtonsStackView = newValue
            updateSubviewAppearances()
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            updateSubviewAppearances()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .collectionViewBackgroundColor
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        updateDefaultLabelFontForCurrentTraitCollection()
        updateSubviewAppearances()
    }

    private func updateSubviewAppearances() {
        contentView.backgroundColor = backgroundColor
        contentView.isOpaque = true

        leftButton?.backgroundColor = backgroundColor
        leftButton?.isOpaque = true

//        rightButton?.backgroundColor = backgroundColor
//        rightButton?.isOpaque = true

        rightButtonsStackView?.backgroundColor = backgroundColor
        rightButtonsStackView?.isOpaque = true

        titleView?.backgroundColor = backgroundColor
        titleView?.isOpaque = true

        defaultTitleLabel.backgroundColor = backgroundColor
        defaultTitleLabel.isOpaque = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDefaultLabelFontForCurrentTraitCollection()
    }

    private func updateDefaultLabelFontForCurrentTraitCollection() {
        let fontSize: CGFloat = sizeClass.contains(any: .compact) ? 28 : 48
        defaultTitleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    }
}
