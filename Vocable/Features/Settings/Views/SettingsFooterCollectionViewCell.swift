//
//  SettingsFooterCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/10/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class SettingsFooterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var versionLabel: UILabel!
    
    func setup(versionLabel: String) {
        self.versionLabel.text = versionLabel
    }
    
}
