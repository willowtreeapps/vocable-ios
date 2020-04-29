//
//  SettingsToggleCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

final class EditPhrasesCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    override func updateContentViews() {
        super.updateContentViews()

        borderedView.fillColor = .defaultCellBackgroundColor
    }

}
