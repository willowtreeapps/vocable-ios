//
//  PresetItemCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetItemCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet fileprivate weak var textLabel: UILabel!
    
    var font: UIFont = .systemFont(ofSize: 28, weight: .bold) {
        didSet {
            textLabel.font = font
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.cornerRadius = 8
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        
        updateContentViews()
        backgroundView = borderedView
    }
    
    override func updateContentViews() {
        super.updateContentViews()

        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
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

class CategoryItemCollectionViewCell: PresetItemCollectionViewCell {
    
    override func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : .categoryBackgroundColor
        borderedView.backgroundColor = .categoryBackgroundColor
        borderedView.isOpaque = true
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
    }
}
