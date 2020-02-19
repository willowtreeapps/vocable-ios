//
//  CategoryContainerCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryContainerCollectionViewCell: VocableCollectionViewCell, UICollectionViewDelegate {
            
    lazy var pageViewController = CategoriesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
    }
    
    func paginate(_ direction: UIPageViewController.NavigationDirection) {
        pageViewController.page(direction)
    }
    
    override func updateContentViews() { /* No-op */ }
}
