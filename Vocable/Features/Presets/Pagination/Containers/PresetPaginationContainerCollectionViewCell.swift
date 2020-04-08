//
//  PresetPaginationCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class PresetPaginationContainerCollectionViewCell: VocableCollectionViewCell {
    var presetCollectionViewController: PresetCollectionViewController?
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        presetCollectionViewController = PresetCollectionViewController(collectionViewLayout: PresetCarouselGridLayout())
    }
    
    func paginate(_ direction: UIPageViewController.NavigationDirection) {
        if direction == .forward {
            presetCollectionViewController?.scrollToNextPage()
        } else if direction == .reverse {
            presetCollectionViewController?.scrollToPreviousPage()
        }
    }
}
