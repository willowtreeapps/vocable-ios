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
    }
    
    private func setupPageViewController() {
        
        pageViewController.view.frame = contentView.frame
        let pageView = pageViewController.view!
        
        contentView.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func paginate(_ direction: PaginationDirection) {
        pageViewController.page(direction)
    }
}
