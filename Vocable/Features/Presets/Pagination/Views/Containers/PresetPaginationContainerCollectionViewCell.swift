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

    private var _collectionViewController: PresetCollectionViewController?
    var presetCollectionViewController: PresetCollectionViewController {
        if _collectionViewController == nil {
            _collectionViewController = PresetCollectionViewController()
        }
        return _collectionViewController!
    }
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _collectionViewController = nil
    }
    
    func paginate(_ direction: UIPageViewController.NavigationDirection) {
        if direction == .forward {
            presetCollectionViewController.scrollToNextPage()
        } else if direction == .reverse {
            presetCollectionViewController.scrollToPreviousPage()
        }
    }
}
