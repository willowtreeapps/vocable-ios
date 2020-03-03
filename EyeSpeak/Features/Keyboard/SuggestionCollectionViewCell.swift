//
//  PresetItemCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    
    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            borderedView.roundedCorners = roundedCorners
        }
    }
    
    func setup(title: String) {
        if title.isEmpty {
            textLabel.text = title
        } else {
            textLabel.text = "\"" + title + "\""
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        adjustBackgroundColorForSizeClass()
    }
    
    override func updateContentViews() {
        super.updateContentViews()
        borderedView.fillColor = isSelected ? .cellSelectionColor : .categoryBackgroundColor
        adjustBackgroundColorForSizeClass()
        
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
        textLabel.font = .systemFont(ofSize: 22, weight: .bold)
    }
    
    private func adjustBackgroundColorForSizeClass() {
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            borderedView.backgroundColor = .clear
        } else {
            borderedView.backgroundColor = .categoryBackgroundColor
        }
    }
    
}
