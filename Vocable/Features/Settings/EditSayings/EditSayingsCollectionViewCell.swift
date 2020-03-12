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
    
    @IBOutlet var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func updateContentViews() {
        super.updateContentViews()

        textLabel.textColor = .defaultTextColor
        textLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        borderedView.fillColor = .defaultCellBackgroundColor
    }

    func setup(title: String) {
        textLabel.text = title
    }
    
}
