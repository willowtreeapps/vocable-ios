//
//  CategoryPaginationCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryPaginationContainerCollectionViewCell: VocableCollectionViewCell {
    var pageViewController: CategoryCollectionViewController?
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        pageViewController?.view.removeFromSuperview()
//        pageViewController?.removeFromParent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        pageViewController = CategoryCollectionViewController()
    }
}
