//
//  KeyboardKeyCollectionView.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/13/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class KeyboardKeyCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet fileprivate weak var textLabel: UILabel!
    
    var font: UIFont = .systemFont(ofSize: 48, weight: .bold) {
        didSet {
            textLabel.font = font
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .defaultCellBackgroundColor
        
        updateContentViews()
        backgroundView = borderedView
    }
    
    override func updateContentViews() {
        super.updateContentViews()
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
        textLabel.font = font
    }

    func setup(title: String) {
        textLabel.text = title
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
