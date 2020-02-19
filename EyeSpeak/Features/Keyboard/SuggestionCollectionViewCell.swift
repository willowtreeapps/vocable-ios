//
//  PresetItemCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: CategoryItemCollectionViewCell {

    override func setup(title: String) {
        if title.isEmpty {
            super.setup(title: title)
        } else {
            super.setup(title: "\"" + title + "\"")
        }
    }
    
}
