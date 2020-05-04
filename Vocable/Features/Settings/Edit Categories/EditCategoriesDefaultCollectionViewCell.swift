//
//  EditCategoriesRegularCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class EditCategoriesDefaultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moveDownButton: GazeableButton!
    @IBOutlet weak var moveUpButton: GazeableButton!
    
    @IBOutlet private weak var categoryNameLabel: UILabel!
    
    @IBOutlet weak var showCategoryDetailButton: GazeableButton!
    
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var bottomSeparator: UIView!
    
    var separatorMask: CellSeparatorMask = .both {
        didSet {
            updateSeparatorMask()
        }
    }
    
    var ordinalButtonMask: CellOrdinalButtonMask = .both {
        didSet {
            updateOrdinalButtonMask()
        }
    }
    
    func setup(title: NSMutableAttributedString) {
        categoryNameLabel.attributedText = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        updateSeparatorMask()
    }
    
    private func updateSeparatorMask() {
        topSeparator?.isHidden = !separatorMask.contains(.top)
        bottomSeparator?.isHidden = !separatorMask.contains(.bottom)
    }
    
    private func updateOrdinalButtonMask() {
        moveUpButton.isEnabled = ordinalButtonMask.contains(.topUpArrow)
        moveDownButton.isEnabled = ordinalButtonMask.contains(.bottomDownArrow)
    }
	
}
