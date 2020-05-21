//
//  PresetItemCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetItemCollectionViewCell: VocableCollectionViewCell {
    let textLabel = UILabel(frame: .zero)
    
    override func updateContentViews() {
        super.updateContentViews()

        let textColor: UIColor = {
            if isSelected {
                return .selectedTextColor
            }
            if !isEnabled {
                return UIColor.defaultTextColor.disabled(blending: borderedView.backgroundColor)
            }
            return .defaultTextColor
        }()

        textLabel.textColor = textColor
        textLabel.backgroundColor = .clear
        textLabel.isOpaque = true
        textLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {

        contentView.preservesSuperviewLayoutMargins = true

        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)

        // Needs a weak spot that can break while resizing to avoid
        // constraint errors
        let rightConstraint = textLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
        rightConstraint.priority = .init(999)
        NSLayoutConstraint.activate([
            rightConstraint,
            textLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        updateContentViews()
    }

    func setup(title: String) {
        textLabel.text = title
        updateContentViews()
    }
    
    func setup(with image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSAttributedString(attachment: systemImageAttachment)
        
        textLabel.attributedText = attributedString
        updateContentViews()
    }
}

class CategoryItemCollectionViewCell: PresetItemCollectionViewCell {
    
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            borderedView.roundedCorners = roundedCorners
        }
    }
    
    override func updateContentViews() {
        super.updateContentViews()

        borderedView.fillColor = {
            var result: UIColor
            if isSelected {
                result = .cellSelectionColor
            } else {
                result = .categoryBackgroundColor
            }
            if isHighlighted && isTrackingTouches {
                result = result.darkenedForHighlight()
            }
            return result
        }()
        borderedView.backgroundColor = sizeClass.contains(any: .compact)
            ? .collectionViewBackgroundColor : .categoryBackgroundColor
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
        textLabel.font = .systemFont(ofSize: 22, weight: .bold)
    }
}
