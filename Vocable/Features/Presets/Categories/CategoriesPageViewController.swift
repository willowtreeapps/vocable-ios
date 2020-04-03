//
//  CategoriesPageViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

class CategoriesPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var itemsPerPage: Int {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return 4
        } else if traitCollection.verticalSizeClass == .compact {
            return 3
        }
        
        return 1
    }
    
    private var _pages: [UIViewController]?
    private var pages: [UIViewController] {
        if _pages == nil {
            _pages = categoryViewModels.chunked(into: itemsPerPage).map { viewModels in
                let collectionViewController = CategoryPageCollectionViewController(collectionViewLayout: CategoryPageCollectionViewController.createLayout(with: viewModels.count))
                collectionViewController.items = viewModels
                return collectionViewController
            }
        }
        
        return _pages ?? []
    }
    
    private lazy var categoryViewModels: [CategoryViewModel] =
        Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                          sortDescriptors: [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)])
            .compactMap { CategoryViewModel($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let viewControllerToSelect = pages.first(where: {
            (($0 as? CategoryPageCollectionViewController)?.items.contains(ItemSelection.selectedCategory) ?? false)
        })
        
        if let viewController = viewControllerToSelect {
            setViewControllers([viewController], direction: .forward, animated: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        _pages = nil 
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        return pages[safe: index - 1] ?? pages.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        return pages[safe: index + 1] ?? pages.first
    }
}
