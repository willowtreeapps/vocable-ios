//
//  EditCategoryToggleCollectionViewCell.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class EditCategoryToggleCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet weak var showCategorySwitch: UISwitch!
    @IBOutlet weak var showCategoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showCategorySwitch.isEnabled = true
        showCategorySwitch.isUserInteractionEnabled = false
        showCategoryLabel.text = NSLocalizedString("Show", comment: "Show category toggle label.")
        
    }
}
