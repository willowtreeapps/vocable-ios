//
//  EditCategoryRemoveCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class EditCategoryRemoveCollectionViewCell: VocableCollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!

    override func updateContentViews() {
        super.updateContentViews()
        textLabel?.textColor = isEnabled ? .defaultTextColor : .disabledTextColor
    }

}
