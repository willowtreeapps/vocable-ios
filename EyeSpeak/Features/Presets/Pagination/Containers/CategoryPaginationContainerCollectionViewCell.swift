//
//  CategoryPaginationCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryPaginationContainerCollectionViewCell: PaginationContainerCollectionViewCell {
    
    var selectedCategory: CategoryViewModel! {
        didSet {
            pageViewController = CategoriesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        }
    }
            
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
    }
}
