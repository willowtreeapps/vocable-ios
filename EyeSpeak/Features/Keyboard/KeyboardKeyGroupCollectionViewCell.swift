//
//  KeyboardKeyGroupCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class KeyboardKeyGroupCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    func setup(title: String) {
        guard !title.isEmpty else {
            return
        }
        
        title.forEach { character in
            let label = UILabel()
            label.textColor = .defaultTextColor
            label.font = .boldSystemFont(ofSize: 48)
            label.text = "\(character)"
            stackView.addArrangedSubview(label)
        }
    }
    
    override func prepareForReuse() {
        stackView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
        borderedView.isOpaque = true
    }
    
}
