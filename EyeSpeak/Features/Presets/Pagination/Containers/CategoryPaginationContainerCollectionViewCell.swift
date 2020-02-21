//
//  CategoryPaginationCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryPaginationContainerCollectionViewCell: PaginationContainerCollectionViewCell {
            
    override func awakeFromNib() {
        super.awakeFromNib()
        pageViewController = CategoriesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
    }
}
