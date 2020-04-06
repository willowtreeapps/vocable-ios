//
//  PresetPaginationCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetPaginationContainerCollectionViewCell: VocableCollectionViewCell {
    var presetCollectionViewController: PresetCollectionViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        presetCollectionViewController = PresetCollectionViewController(collectionViewLayout: CarouselGridLayout())
    }
    
    func paginate(_ direction: UIPageViewController.NavigationDirection) {
        if direction == .forward {
            presetCollectionViewController?.scrollToNextPage()
        } else if direction == .reverse {
            presetCollectionViewController?.scrollToPreviousPage()
        }
    }
}
