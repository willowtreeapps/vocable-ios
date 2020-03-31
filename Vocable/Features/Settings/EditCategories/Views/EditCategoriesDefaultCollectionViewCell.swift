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
    
    func setup(title: String) {
        categoryNameLabel.text = title
    }
}
