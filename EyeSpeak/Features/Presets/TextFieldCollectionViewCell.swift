//
//  TextFieldCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet fileprivate weak var textLabel: UILabel!
    
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
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = .collectionViewBackgroundColor
        textLabel.isOpaque = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateContentViews()
    }

    func setup(title: NSAttributedString) {
        textLabel.attributedText = title
    }
    
    func setup(with image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSAttributedString(attachment: systemImageAttachment)
        
        textLabel.attributedText = attributedString
    }
    
}
