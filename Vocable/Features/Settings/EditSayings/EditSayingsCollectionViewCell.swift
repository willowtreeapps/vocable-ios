//
//  SettingsToggleCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import Combine

class EditSayingsCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var editButton: UIButton!
    
    override func updateContentViews() {
        super.updateContentViews()

        textLabel.textColor = .defaultTextColor
        textLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        
        borderedView.fillColor = .defaultCellBackgroundColor
    }

    func setup(title: String) {
        textLabel.text = title
    }
    
}
