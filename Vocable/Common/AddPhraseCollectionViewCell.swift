//
//  AddPhraseCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

class AddPhraseCollectionViewCell: PresetItemCollectionViewCell {

    private let borderWidth = 6.0
    private let cornerRadius = 8.0

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

        fillColor = .collectionViewBackgroundColor

        textLabel.numberOfLines = 1
        setup(title: NSLocalizedString("preset.category.add.phrase.title", comment: "Add phrase button title"),
              with: UIImage(systemName: "plus"))
        updateContentViews()
    }

    override func updateContentViews() {
        super.updateContentViews()

        if isHighlighted && !isSelected {
            borderedView.borderColor = .cellBorderHighlightColor
        } else if isSelected {
            borderedView.borderColor = .cellSelectionColor
        } else {
            borderedView.borderColor = .categoryBackgroundColor
        }

        borderedView.backgroundColor = .collectionViewBackgroundColor
        borderedView.borderWidth = isSelected ? 0 : borderWidth
        borderedView.isOpaque = true
        borderedView.cornerRadius = cornerRadius
        borderedView.borderDashPattern = [6, 6]

        layoutMargins = .init(uniform: cornerRadius + borderWidth)
    }
}
