//
//  EditCategoriesRegularCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class EditCategoriesDefaultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var moveDownButton: GazeableButton!
    @IBOutlet var moveUpButton: GazeableButton!
    
    @IBOutlet private var categoryNameLabel: UILabel!
    
    @IBOutlet var showCategoryDetailButton: GazeableButton!
    
<<<<<<< HEAD
    @IBOutlet private var topSeparator: UIView!
    @IBOutlet private var bottomSeparator: UIView!
    
    var separatorMask: CellSeparatorMask = .both {
        didSet{
            updateSeparatorMask()
        }
    }
=======
    @IBOutlet var topSeparator: UIView!
    @IBOutlet var bottomSeparator: UIView!
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
    
    func setup(title: String) {
        categoryNameLabel.text = title
    }
<<<<<<< HEAD
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateSeparatorMask()
    }
    
    private func updateSeparatorMask() {
        topSeparator?.isHidden = !separatorMask.contains(.top)
        bottomSeparator?.isHidden = !separatorMask.contains(.bottom)
    }
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
}
