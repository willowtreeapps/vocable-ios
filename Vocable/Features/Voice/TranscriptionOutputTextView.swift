//
//  TranscriptionOutputTextView.swift
//  Vocable
//
//  Created by Chris Stroud on 1/8/21.
//

import UIKit

@IBDesignable
class TranscriptionOutputTextView: UITextView, NSLayoutManagerDelegate {

    override var text: String? {
        didSet {
            updateTextAttributes()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            updateTextAttributes()
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
        textColor = .defaultTextColor
        tintColor = .systemGreen
        backgroundColor = .primaryBackgroundColor

        isEditable = false
        isSelectable = false
        isScrollEnabled = true
        isUserInteractionEnabled = false

        textContainer.lineFragmentPadding = 0
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = 0

        layoutManager.delegate = self

        layoutMargins = .zero
        textContainerInset = .zero
        insetsLayoutMarginsFromSafeArea = true
        allowsEditingTextAttributes = false
        contentInsetAdjustmentBehavior = .never
        textAlignment = .left
        clipsToBounds = true
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        textContainerInset = layoutMargins
        scrollToEnd()
    }

    override func insertText(_ text: String) {
        super.insertText(text)
        updateTextAttributes()
    }

    private func fontForCurrentTraitCollection() -> UIFont {
        let sizeClass = (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass)
        let fontSize: CGFloat = sizeClass == (.regular, .regular) ? 40 : 28
        let desiredFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        return desiredFont
    }

    func updateTextAttributes() {

        let beginning = beginningOfDocument
        let ending = endOfDocument
        let length = offset(from: beginning, to: ending)
        let documentRange = NSRange(location: 0, length: length)

        var fragmentRanges = [(range: NSRange, rect: CGRect)]()
        layoutManager.enumerateLineFragments(forGlyphRange: documentRange) { (rect, _, _, range, _) in
            fragmentRanges.append((range: range, rect: rect))
        }
        fragmentRanges = fragmentRanges.reversed()

        let font = fontForCurrentTraitCollection()

        textStorage.setAttributes([.foregroundColor: UIColor.primaryBackgroundColor, .font: font], range: documentRange)

        for (index, fragmentRange) in fragmentRanges.enumerated() {
            let blendAmount: CGFloat = {
                if fragmentRanges.count < 2 {
                    return 0.0
                }
                return CGFloat(index) / 2
            }()
            let blendedColor = UIColor.primaryBackgroundColor.blended(with: .cellSelectionColor, amount: blendAmount)
            textStorage.addAttribute(.foregroundColor, value: blendedColor, range: fragmentRange.range)
        }
    }

    private func scrollToEnd() {
        let endOffset = offset(from: beginningOfDocument, to: endOfDocument)
        let documentRange = NSRange(location: endOffset, length: 0)
        scrollRangeToVisible(documentRange)
    }

    func layoutManager(_ layoutManager: NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFrom oldSize: CGSize) {
        updateTextAttributes()
        scrollToEnd()
    }

    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if layoutFinishedFlag {
            scrollToEnd()
        }
    }
}
