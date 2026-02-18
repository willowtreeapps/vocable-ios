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

class TextEditorViewController: VocableViewController, UICollectionViewDelegate, VocableSpeechSynthesizerDelegate, KeyboardViewDelegate {

    struct Configuration {
        var leftItemConfiguraton: TextEditorNavigationButton.Configuration?
        var rightItemConfiguration: TextEditorNavigationButton.Configuration?
    }

    var delegate: TextEditorConfigurationProviding?

    private let textView = OutputTextView(frame: .zero)
    private let leftButton = TextEditorNavigationButton()
    private let rightButton = TextEditorNavigationButton()
    private let keyboardView = KeyboardView()
    private var needsConfigurationUpdate = true
    private var volatileConstraints = [NSLayoutConstraint]()

    // MARK: Text Properties

    var text: String? {
        textView.attributedText?.string
    }

    // Single source of truth for the state of edited text
    private var textTransaction = TextTransaction(text: "") {
        didSet {
            textView.attributedText = textTransaction.attributedText
            textView.cursorIndex = textTransaction.cursorIndex
            updateSuggestions(textTransaction)
            delegate?.textEditorViewController(self, textDidChange: self.text)
        }
    }

    private let textExpression = TextExpression()

    private var suggestions: [String] = [] {
        didSet {
            guard !suggestions.elementsEqual(oldValue) else {
                return
            }
            keyboardView.suggestions = suggestions
        }
    }

    // MARK: Speech Properties

    private var speechSynthesizer: VocableSpeechSynthesizer!

    private var isSpeaking: Bool = false {
        didSet {
            if #available(iOS 17.0, *) {
                self.traitOverrides.isSpeaking = isSpeaking
            }
        }
    }

    private var speakingRange: NSRange? {
        didSet {
            guard oldValue != speakingRange else { return }
            textTransaction.setSpeakingRange(speakingRange)
        }
    }

    // MARK: Initializers

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

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        speechSynthesizer = VocableSpeechSynthesizer(delegate: self)
        keyboardView.delegate = self
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.frame.size.width = view.bounds.width
        view.addSubview(keyboardView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.accessibilityID = .shared.keyboard.outputTextView
        textView.textAlignment = .natural

        navigationBar.leftButton = leftButton
        navigationBar.rightButton = rightButton

        setNeedsUpdateConfiguration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let initialText = delegate?.textEditorViewControllerInitialValue(self) ?? ""
        textTransaction = TextTransaction(text: initialText, intent: .lastCharacter, cursorIndex: initialText.count)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
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
                keyboardView.topAnchor.constraint(
                    equalTo: navigationBar.bottomAnchor,
                    constant: 8
                )
            ]
        } else {
            navigationBar.titleView = nil
            if textView.superview != view {
                view.addSubview(textView)
            }
            constraints += [
                textView.heightAnchor.constraint(greaterThanOrEqualTo: navigationBar.layoutMarginsGuide.heightAnchor, multiplier: 2),
                textView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 8),
                textView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
                textView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
                keyboardView.topAnchor.constraint(greaterThanOrEqualTo: textView.bottomAnchor)
            ]
        }

        // Collection view
        constraints += [
            keyboardView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }

    // MARK: External configuration

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

    // MARK: Suggestions

    private func updateSuggestions(_ transaction: TextTransaction) {
        if transaction.isHint || transaction.text.last == " " {
            suggestions = []
        } else {
            textExpression.replace(text: transaction.text)
            suggestions = textExpression.suggestions()
        }
    }

    // MARK: VocableSpeechSynthesizerDelegate

    func voiceProfilePreviewDidBegin(_: AVSpeechSynthesisVoice?) {
        isSpeaking = true
    }

    func voiceProfilePreviewDidEnd() {
        isSpeaking = false
        speakingRange = nil
    }

    func voiceSpeechSynthesisWillSpeakRange(_ range: NSRange, utterance: AVSpeechUtterance) {
        speakingRange = range
    }

    func keyboardViewDidSelectSuggestion(_ suggestion: String) {
        textTransaction.insert(suggestion)
    }

    func keyboardViewDidSelectKey(_ value: KeyboardLayoutKey) {
        switch value.action {
        case .insertCharacter(let character):
            textTransaction.append(String(character))
        case .clear:
            textTransaction.clear()
        case .backspace:
            textTransaction.deleteLastToken()
        case .space:
            textTransaction.append(" ")
        case .speak:
            guard !textTransaction.isHint else {
                break
            }

            Analytics.shared.track(.keyboardPhraseSpoken)
            let utterance = textTransaction.text
            Task { [weak self] in
                await self?.speechSynthesizer.speak(utterance)
            }
        case .moveCursorLeft:
            textTransaction.moveCursorLeft()
        case .moveCursorRight:
            textTransaction.moveCursorRight()
        case .numberPad, .alphabet, .openModifierPicker, .closeModifierPicker, .beginModifier, .endModifier:
            break
        }
    }
}
