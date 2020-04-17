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
        showCategoryLabel.text = NSLocalizedString("category_editor.detail.button.show_category.title", comment: "Show category button label within the category detail screen.")
        
    }
}
