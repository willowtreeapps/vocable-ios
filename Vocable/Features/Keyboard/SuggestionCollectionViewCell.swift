//
//  PresetItemCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    
    func setup(title: String) {
        if title.isEmpty {
            textLabel.text = title
        } else {
            textLabel.text = "\"" + title + "\""
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustBackgroundColorForSizeClass()
    }
    
    override func updateContent() {
        super.updateContent()
        borderedView.fillColor = isSelected ? .cellSelectionColor : .categoryBackgroundColor
        adjustBackgroundColorForSizeClass()
        
        guard let textLabel = textLabel else { return }
        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = borderedView.fillColor
        textLabel.isOpaque = true
        textLabel.font = .systemFont(ofSize: 22, weight: .bold)
    }
    
    private func adjustBackgroundColorForSizeClass() {
        if sizeClass.contains(any: .compact) {
            borderedView.backgroundColor = .clear
        } else {
            borderedView.backgroundColor = .categoryBackgroundColor
        }
    }
    
}
