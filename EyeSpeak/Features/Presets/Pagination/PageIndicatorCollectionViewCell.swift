//
//  PageIndicatorCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PageIndicatorCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet private weak var pageLabel: UILabel!
    
    var pageInfo: String = "" {
        didSet {
            pageLabel.text = pageInfo
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fillColor = .collectionViewBackgroundColor
    }
}
