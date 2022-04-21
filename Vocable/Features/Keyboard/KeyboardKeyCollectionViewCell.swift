//
//  KeyboardKeyCollectionView.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/13/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class KeyboardKeyCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet fileprivate weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
    }
    
    override func updateContent() {
        super.updateContent()
        
        guard let textLabel = textLabel else { return }
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
    }

    func setup(title: String) {
        textLabel.text = title
    }
    
    func setup(with image: UIImage?) {
        guard let image = image, let font = textLabel.font else {
            return
        }
        
        let size = CGSize(width: bounds.width, height: font.ascender)
        
        let scaledCellBounds = CGRect(origin: .zero, size: size)
        let scaledRect = AVMakeRect(aspectRatio: image.size, insideRect: scaledCellBounds)
        let finalRect = CGRect(origin: .zero, size: scaledRect.size)
        
        let systemImageAttachment = NSTextAttachment(image: image)
        systemImageAttachment.bounds = finalRect
        let finalAttributedString = NSAttributedString(attachment: systemImageAttachment)
        
        textLabel.attributedText = finalAttributedString
    }
}

class SpeakFunctionKeyboardKeyCollectionViewCell: KeyboardKeyCollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        fillColor = UIColor.highlightedTextColor!
    }
    
    override func updateContent() {
        super.updateContent()

        textLabel?.textColor = isSelected ? .selectedTextColor : .collectionViewBackgroundColor
    }
}
