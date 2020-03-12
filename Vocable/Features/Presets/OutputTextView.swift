//
//  OutputTextView.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final private class TextCursorBeamView: UIView {

    override func tintColorDidChange() {
        super.tintColorDidChange()
        backgroundColor = tintColor
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        scheduleBlinkAnimation(afterDelay: 1)
        backgroundColor = tintColor
    }

    private func scheduleBlinkAnimation(afterDelay delay: TimeInterval = 0) {

        func scheduleBlink(withDelay delay: TimeInterval) {
            UIView.animateKeyframes(withDuration: 1, delay: delay, options: [.beginFromCurrentState], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.33) {
                    self.alpha = 0
                }
                UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.33) {
                    self.alpha = 1
                }
            }, completion: { _ in
                scheduleBlink(withDelay: 0)
            })
        }

        layer.removeAllAnimations()
        scheduleBlink(withDelay: delay)
    }
}

@IBDesignable
class OutputTextView: UITextView {

    override var text: String? {
        didSet {
            updateCursorPosition()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            updateCursorPosition()
        }
    }

    @IBInspectable var isCursorHidden: Bool {
        set {
            beamView.isHidden = newValue
        }
        get {
            beamView.isHidden
        }
    }

    private let beamView = TextCursorBeamView(frame: .zero)

    override var frame: CGRect {
        didSet {
            updateCursorPosition()
        }
    }

    override var bounds: CGRect {
        didSet {
            updateCursorPosition()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        textColor = .white
        tintColor = .highlightedTextColor
        backgroundColor = .collectionViewBackgroundColor

        isEditable = false
        isSelectable = false
        isScrollEnabled = false
        isUserInteractionEnabled = false

        textContainer.lineFragmentPadding = 0
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        textContainer.lineBreakMode = .byTruncatingHead

        layoutMargins = .zero
        textContainerInset = .zero
        allowsEditingTextAttributes = false
        contentInsetAdjustmentBehavior = .never

        updateForCurrentTraitCollection()

        addSubview(beamView)
        updateCursorPosition()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateForCurrentTraitCollection()
    }

    private func updateForCurrentTraitCollection() {
        if traitCollection.verticalSizeClass == .compact {
            textContainer.maximumNumberOfLines = 1
        } else {
            textContainer.maximumNumberOfLines = 0
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        updateCursorPosition()
    }

    private func updateCursorPosition() {
        let rect = caretRect(for: endOfDocument)
        beamView.frame = rect
    }
}
