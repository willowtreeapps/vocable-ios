//
//  CategoriesPageViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

class CategoriesPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let itemsPerPage = 4
    
    var selectedCategory: CategoryViewModel?
    
    private lazy var pages: [UIViewController] = categoryViewModels.chunked(into: itemsPerPage).map { viewModels in
        let collectionViewController = CategoryPageCollectionViewController(collectionViewLayout: CategoryPageCollectionViewController.createLayout(with: viewModels.count))
                collectionViewController.items = viewModels
                return collectionViewController
    }
    
    private lazy var categoryViewModels: [CategoryViewModel] =
        Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                          sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
            .compactMap { CategoryViewModel($0) }
    
    init(selectedCategory: CategoryViewModel) {
        self.selectedCategory = selectedCategory
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectCategory(notification:)), name: .didSelectCategoryNotificationName, object: nil)
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
    
    @objc private func didSelectCategory(notification: NSNotification) {
        guard let category = notification.object as? CategoryViewModel else {
            return
        }
        
        selectedCategory = category
    }
}
