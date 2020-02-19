//
//  CategoryContainerCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryContainerCollectionViewCell: VocableCollectionViewCell, UICollectionViewDelegate {
            
    private lazy var pageViewController = CategoriesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupPageViewController()
        borderedView.fillColor = .categoryBackgroundColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
    }
    
    private func setupPageViewController() {
        pageViewController.view.frame = contentView.frame.inset(by: contentView.layoutMargins)
        
        let pageView = pageViewController.view!
        contentView.addSubview(pageView)
    }
    
    func paginate(_ direction: PaginationDirection) {
        pageViewController.page(direction)
    }
    
    override func updateContentViews() {
        // no-op
    }
}
