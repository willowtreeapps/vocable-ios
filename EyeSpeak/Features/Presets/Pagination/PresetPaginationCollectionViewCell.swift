//
//  PresetPaginationCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetPaginationCollectionViewCell: PaginationContainerCollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageViewController = PresetsPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
}
