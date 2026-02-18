//
//  OutputTextView.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable
class OutputTextView: UITextView {

    override var text: String? {
        didSet {
            updateCursorPosition()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            updateFontForTraitCollection()
            updateCursorPosition()
        }
    }

    @IBInspectable var isCursorHidden: Bool {
        get {
            beamView.isHidden
        }
        set {
            beamView.isHidden = newValue
        }
    }

    /// Insertion point for the caret; clamped to 0...text length. When not set, caret stays at end.
    var cursorIndex: Int = -1 {
        didSet {
            updateCursorPosition()
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
        updateFontForTraitCollection()
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
        let length = attributedText?.length ?? 0
        let index: Int
        if cursorIndex >= 0 {
            index = min(max(0, cursorIndex), length)
        } else {
            index = length
        }
        let position = position(from: beginningOfDocument, offset: index) ?? endOfDocument
        let rect = caretRect(for: position)
        beamView.frame = rect
    }
    
    private func updateFontForTraitCollection() {
        let desiredFont = UIFont.textEditor(satisfying: traitCollection)
        let attributedFont: UIFont? = {
            guard let len = attributedText?.length, len > 0 else { return nil }
            return attributedText?.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        }()
        let currentFont = attributedFont ?? self.font
        if currentFont != desiredFont {
            self.font = desiredFont
        }
    }
}
