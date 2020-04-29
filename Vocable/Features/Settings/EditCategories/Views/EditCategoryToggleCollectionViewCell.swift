//
//  EditCategoryToggleCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class EditCategoryToggleCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet weak var showCategorySwitch: UISwitch!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        showCategorySwitch.isUserInteractionEnabled = false
    }

    override func updateContentViews() {
        super.updateContentViews()
        textLabel?.textColor = isEnabled ? .defaultTextColor : .disabledTextColor
    }
}
