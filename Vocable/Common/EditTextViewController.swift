//
//  EditTextViewController.swift
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

class EditTextViewController: VocableViewController, UICollectionViewDelegate {

    var initialText: String = ""
    let textView = OutputTextView(frame: .zero)

    var shouldWarnOnDismiss = true
    var editTextCompletionHandler: (String) -> Void = { (_) in
        assertionFailure("Completion not handled")
    }

    @PublishedValue private(set) var text: String?

    private var textHasChanged = false
    private var disposables = Set<AnyCancellable>()
    private var volatileConstraints = [NSLayoutConstraint]()
    
    private lazy var keyboardViewController = KeyboardViewController()

    private lazy var confirmEditButton: GazeableButton = {
        let button = GazeableButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.accessibilityIdentifier = "keyboard.saveButton"
        button.addTarget(self, action: #selector(confirmEdit(_:)), for: .primaryActionTriggered)
        return button
    }()

    private lazy var dismissButton: GazeableButton = {
        let button = GazeableButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.accessibilityIdentifier = "keyboard.dismissButton"
        button.addTarget(self, action: #selector(dismiss(_:)), for: .primaryActionTriggered)
        return button
    }()

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

        let initialAttributedText = NSAttributedString(string: initialText)
        keyboardViewController.attributedText = initialAttributedText
        confirmEditButton.isEnabled = false

        navigationBar.leftButton = dismissButton
//        navigationBar.rightButton = confirmEditButton
        navigationBar.rightButtons = [confirmEditButton]

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.accessibilityIdentifier = "keyboard.textView"
        textView.textAlignment = .natural
        
        keyboardViewController.$attributedText.sink(receiveValue: { (attributedText) in
            self.textView.attributedText = attributedText
            let didTextChange = self.initialText != attributedText?.string

            let isTextEmpty = attributedText?.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            self.textHasChanged = didTextChange
            self.confirmEditButton.isEnabled = didTextChange && !isTextEmpty
            self.text = attributedText?.string
        }).store(in: &disposables)
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

    @objc private func dismiss(_ sender: Any) {
        if textHasChanged {
            handleDismissAlert()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func confirmEdit(_ sender: Any) {
        let trimmed = textView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        editTextCompletionHandler(trimmed)
        dismiss(animated: true, completion: nil)
    }
    
    private func handleDismissAlert() {
        func discardChangesAction() {
            dismiss(animated: true, completion: nil)
        }

        guard shouldWarnOnDismiss else {
            discardChangesAction()
            return
        }
        
        let title = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.title",
                                      comment: "Exit edit sayings alert title")
        let discardButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.discard.title",
                                                   comment: "Discard changes alert action title")
        let continueButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.continue_editing.title",
                                                    comment: "Continue editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: continueButtonTitle))
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, style: .destructive, handler: discardChangesAction))
        self.present(alert, animated: true)
    }
    
}
