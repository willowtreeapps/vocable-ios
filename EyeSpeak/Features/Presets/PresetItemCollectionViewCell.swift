//
//  PresetItemCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var textLabel: UILabel!
    
    fileprivate let borderedView = BorderedView()

    fileprivate var defaultBackgroundColor: UIColor?
    
    override var isHighlighted: Bool {
        didSet {
             updateContentViews()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateContentViews()
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
    
    fileprivate func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
        borderedView.isOpaque = true

        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
    }
    
    var fillColor: UIColor = .defaultCellBackgroundColor {
        didSet {
            updateContentViews()
        }
    }

    func setup(title: String) {
        textLabel.text = title
    }
    
    func changeTitleFont(font: UIFont) {
        textLabel.font = font
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
    
    override fileprivate func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : .categoryBackgroundColor
        borderedView.backgroundColor = .categoryBackgroundColor
        borderedView.isOpaque = true
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
    }
}

class KeyboardKeyGroupCollectionViewCell: PresetItemCollectionViewCell {
    
    var title: String = "" {
        didSet {
            updateTitleLabel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateTitleLabel()
    }
    
    override func setup(title: String) {
        self.title = title
    }
    
    override fileprivate func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
        borderedView.isOpaque = true
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
    }
    
    private func updateTitleLabel() {
        guard !title.isEmpty else {
            return
        }
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .kern: 45 // FIXME: the text's kerning should fit the label's width
        ]
        
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(textAttributes, range: NSRange(location: 0, length: attributedString.length - 1))
        
        textLabel.attributedText = attributedString
    }
}
