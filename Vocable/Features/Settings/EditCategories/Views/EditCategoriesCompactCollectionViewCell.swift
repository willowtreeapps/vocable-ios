//
//  EditCategoriesCompactCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class EditCategoriesCompactCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var moveDownButton: GazeableButton!
    @IBOutlet var moveUpButton: GazeableButton!
    
    @IBOutlet var categoryNameLabel: UILabel!
    
    @IBOutlet var showCategoryDetailButton: GazeableButton!
    
    func setup(title: String) {
        categoryNameLabel.text = title
    }
}
