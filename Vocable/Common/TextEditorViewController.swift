//
//  TextEditorViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData
import Combine

protocol TextEditorConfigurationProviding {
    mutating func textEditorViewController(_: TextEditorViewController, textDidChange text: String?)
    func textEditorViewControllerConfiguration(_: TextEditorViewController) -> TextEditorViewController.Configuration
    func textEditorViewControllerInitialValue(_: TextEditorViewController) -> String?
}

class TextEditorViewController: VocableViewController, UICollectionViewDelegate {

    struct Configuration {
        var leftItemConfiguraton: TextEditorNavigationButton.Configuration?
        var rightItemConfiguration: TextEditorNavigationButton.Configuration?
    }

    let textView = OutputTextView(frame: .zero)

    let leftButton = TextEditorNavigationButton()
    let rightButton = TextEditorNavigationButton()

    var delegate: TextEditorConfigurationProviding?

    private var needsConfigurationUpdate = true

    @PublishedValue private(set) var text: String?

    private var disposables = Set<AnyCancellable>()
    private var volatileConstraints = [NSLayoutConstraint]()
    
    private lazy var keyboardViewController = KeyboardViewController()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
        commonInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        modalPresentationStyle = .fullScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(keyboardViewController)
        keyboardViewController.view.translatesAutoresizingMaskIntoConstraints = false
        keyboardViewController.view.preservesSuperviewLayoutMargins = true
        view.addSubview(keyboardViewController.view)

        let initialAttributedText = NSAttributedString(string: delegate?.textEditorViewControllerInitialValue(self) ?? "")
        keyboardViewController.attributedText = initialAttributedText

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.accessibilityID = .shared.keyboard.outputTextView
        textView.textAlignment = .natural

        navigationBar.leftButton = leftButton
        navigationBar.rightButton = rightButton

        handleTextChange()
        setNeedsUpdateConfiguration()
    }

    private func handleTextChange() {
        keyboardViewController.$attributedText
            .dropFirst()
            .map { [weak self] attributedText -> NSAttributedString? in
                self?.textView.attributedText = attributedText
                return attributedText
            }
            .map { $0?.string }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                self.text = text
                self.delegate?.textEditorViewController(self, textDidChange: text)
            }).store(in: &disposables)
    }

    private func updateForConfiguration() {
        guard let configuration = delegate?.textEditorViewControllerConfiguration(self) else { return }

        leftButton.configure(with: configuration.leftItemConfiguraton)
        rightButton.configure(with: configuration.rightItemConfiguration)
        needsConfigurationUpdate = false
    }

    func setNeedsUpdateConfiguration() {
        needsConfigurationUpdate = true
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        if needsConfigurationUpdate { updateForConfiguration() }
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        NSLayoutConstraint.deactivate(volatileConstraints)

        var constraints = [NSLayoutConstraint]()

        if sizeClass.contains(.vCompact) {
            navigationBar.titleView = textView
            let widthConstraint = textView.widthAnchor.constraint(equalTo: view.widthAnchor)
            widthConstraint.priority = .defaultHigh
            constraints += [
                widthConstraint,
                keyboardViewController.view.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8)
            ]
        } else {
            navigationBar.titleView = nil
            if textView.superview != view {
                view.addSubview(textView)
            }
            constraints += [
                textView.heightAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.heightAnchor, multiplier: 2),
                textView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8),
                textView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
                textView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
                keyboardViewController.view.topAnchor.constraint(equalTo: textView.bottomAnchor)
            ]
        }

        // Collection view
        constraints += [
            keyboardViewController.view.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            keyboardViewController.view.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            keyboardViewController.view.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }
}
