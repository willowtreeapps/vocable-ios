//
//  VocableNavigationBar.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

private class ContentView: UIView {

    var titleLabel: UILabel? {
        didSet {
            updateVolatileView(new: titleLabel, old: oldValue)
        }
    }

    var leftButton: VocableNavigationBarButton? {
        didSet {
            updateVolatileView(new: leftButton, old: oldValue)
        }
    }

    var rightButton: VocableNavigationBarButton? {
        didSet {
            updateVolatileView(new: rightButton, old: oldValue)
        }
    }

    private var volatileConstraints = [NSLayoutConstraint]()

    private func updateVolatileView(new newValue: UIView?, old oldValue: UIView?) {
        guard oldValue != newValue else { return }
        if let newButton = newValue {
            newButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(newButton)
        } else {
            oldValue?.removeFromSuperview()
        }
        updateContentViews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContentViews()
    }

    private func updateContentViews() {
        let fontSize: CGFloat = sizeClass.contains(any: .compact) ? 28 : 48
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        titleLabel?.textColor = .defaultTextColor

        leftButton?.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        rightButton?.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)

        updateContentLayout()
    }

    override var intrinsicContentSize: CGSize {
        if sizeClass.contains(any: .compact) {
            return CGSize(width: UIView.noIntrinsicMetric, height: 54)
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: 100)
    }

    private func updateContentLayout() {

        layoutMargins = .zero

        let buttonSpacing: CGFloat
        if sizeClass.contains(any: .compact) {
            buttonSpacing = 8
        } else {
            buttonSpacing = 16
        }

        NSLayoutConstraint.deactivate(volatileConstraints)

        var constraints = [NSLayoutConstraint]()

        let layoutMargins = layoutMarginsGuide

        // Title label
        if let titleLabel = titleLabel {
            let titleCenterX = titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            titleCenterX.priority = .init(rawValue: 999)
            constraints += [
                titleCenterX,
                titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMargins.leadingAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMargins.trailingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: layoutMargins.centerYAnchor)
            ]
        }

        // Left button
        if let leftButton = leftButton {
            constraints += [
                leftButton.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
                leftButton.bottomAnchor.constraint(equalTo: layoutMargins.bottomAnchor),
                leftButton.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor),
                leftButton.widthAnchor.constraint(equalTo: leftButton.heightAnchor)
            ]

            if let titleLabel = titleLabel {
                constraints += [
                    titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftButton.leadingAnchor, constant: buttonSpacing)
                ]
            }
        }

        // Right button
        if let rightButton = rightButton {
            constraints += [
                rightButton.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
                rightButton.bottomAnchor.constraint(equalTo: layoutMargins.bottomAnchor),
                rightButton.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor),
                rightButton.widthAnchor.constraint(equalTo: rightButton.heightAnchor)
            ]

            if let titleLabel = titleLabel {
                constraints += [
                    titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightButton.leadingAnchor, constant: buttonSpacing)
                ]
            }
        }

        NSLayoutConstraint.activate(constraints)

        invalidateIntrinsicContentSize()
    }
}

class VocableNavigationBar: UIView {

    var title: String? {
        get {
            titleLabel?.text
        }
        set {
            guard let text = newValue else {
                titleLabel = nil
                return
            }
            let label = titleLabel ?? UILabel(frame: .zero)
            label.text = text
            self.titleLabel = label
        }
    }

    private var contentView = ContentView(frame: .zero)
    private var titleLabel: UILabel? {
        get {
            contentView.titleLabel
        }
        set {
            contentView.titleLabel = newValue
        }
    }

    var leftButton: VocableNavigationBarButton? {
        get {
            contentView.leftButton
        }
        set {
            contentView.leftButton = newValue
        }
    }

    var rightButton: VocableNavigationBarButton? {
        get {
            contentView.rightButton
        }
        set {
            contentView.rightButton = newValue
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}
