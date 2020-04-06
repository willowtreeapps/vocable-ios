//
//  CategoryPaginationCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryPaginationContainerCollectionViewCell: VocableCollectionViewCell {
    var categoryCollectionViewController: CategoryCollectionViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        categoryCollectionViewController = CategoryCollectionViewController(collectionViewLayout: CarouselGridLayout())
    }
    
    func paginate(_ direction: UIPageViewController.NavigationDirection) {
        if direction == .forward {
            categoryCollectionViewController?.scrollToNextPage()
        } else if direction == .reverse {
            categoryCollectionViewController?.scrollToPreviousPage()
        }
    }
}
