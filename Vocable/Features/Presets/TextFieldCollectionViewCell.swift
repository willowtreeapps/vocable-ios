//
//  TextFieldCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: VocableCollectionViewCell {

    var isCursorHidden: Bool {
        set {
            textOutputView.isCursorHidden = newValue
        }
        get {
            textOutputView.isCursorHidden
        }
    }

    @IBOutlet fileprivate weak var textOutputView: OutputTextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.cornerRadius = 8
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        super.fillColor = .collectionViewBackgroundColor
        
        updateContentViews()
        backgroundView = borderedView
    }
    
    override func updateContentViews() {
        super.updateContentViews()
        
        textOutputView?.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textOutputView?.backgroundColor = .collectionViewBackgroundColor
        textOutputView?.isOpaque = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContentViews()
        updateAttributedStringForCurrentFont()
    }

    // This allows the font attributes of the attributed string to adapt to potential
    // changes to the trait collection's size class, as defined in the xib
    private func updateAttributedStringForCurrentFont(with newString: NSAttributedString? = nil) {
        guard let input = newString ?? textOutputView?.attributedText else { return }
        let stringRange = NSRange(location: 0, length: input.length)
        let mutableValue = NSMutableAttributedString(attributedString: input)
        mutableValue.addAttribute(.font, value: textOutputView.font as Any, range: stringRange)
        textOutputView.attributedText = mutableValue
    }

    func setup(title: NSAttributedString) {
        updateAttributedStringForCurrentFont(with: title)
    }
    
    func setup(with image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSAttributedString(attachment: systemImageAttachment)
        
        textOutputView.attributedText = attributedString
    }
    
}
