//
//  PaginationContainerCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PaginationContainerCollectionViewCell: VocableCollectionViewCell {
    var pageViewController: UIPageViewController?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pageViewController?.view.removeFromSuperview()
        pageViewController?.removeFromParent()
    }
    
    func paginate(_ direction: UIPageViewController.NavigationDirection) {
        pageViewController?.page(direction)
    }
    
    override func updateContentViews() { /* No-op */ }
}
