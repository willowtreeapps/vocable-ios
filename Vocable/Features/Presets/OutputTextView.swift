//
//  OutputTextView.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final private class TextCursorBeamView: UIView {

    private var blinkTimer: Timer?

    override func tintColorDidChange() {
        super.tintColorDidChange()
        backgroundColor = tintColor
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            blinkTimer?.invalidate()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        scheduleBlinkTimerIfNeeded()
        backgroundColor = tintColor
    }

    override var isHidden: Bool {
        didSet {
            scheduleBlinkTimerIfNeeded()
        }
    }

    private var shouldAllowTimer: Bool {
        guard self.window != nil, !isHidden else {
            return false
        }
        return true
    }

    private func scheduleBlinkTimerIfNeeded() {
        guard shouldAllowTimer else {
            blinkTimer?.invalidate()
            return
        }
        if let current = blinkTimer, current.isValid {
            return
        }
        let timer = Timer(fireAt: Date(),
                          interval: 1.2,
                          target: self,
                          selector: #selector(blinkTimerDidFire(_:)),
                          userInfo: nil,
                          repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        blinkTimer = timer
    }

    @objc
    private func blinkTimerDidFire(_ sender: Timer) {

        guard shouldAllowTimer else {
            blinkTimer?.invalidate()
            return
        }

        guard UIView.areAnimationsEnabled else {
            return
        }

        layer.removeAllAnimations()

        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.beginFromCurrentState], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.33) {
                self.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.33) {
                self.alpha = 1
            }
        }, completion: nil)
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
