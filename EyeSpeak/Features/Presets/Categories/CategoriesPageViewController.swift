//
//  CategoriesPageViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoriesPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let itemsPerPage = 4
    
    var selectedCategory: PresetCategory = .category1
    
    private lazy var pages: [UIViewController] = PresetCategory.allCases.chunked(into: itemsPerPage).map { categories in
        let collectionViewController = CategoryPageCollectionViewController(collectionViewLayout: CategoryPageCollectionViewController.createLayout(with: categories.count))
        collectionViewController.items = categories
        return collectionViewController
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
    
    func page(_ direction: PaginationDirection) {
        switch direction {
        case .forward:
            pageForward()
        case .backward:
            pageBackward()
        }
    }
    
    private func pageForward() {
        guard let currentViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: currentViewController) else {
            return
        }

        setViewControllers([nextViewController], direction: .forward, animated: true)
    }
    
    private func pageBackward() {
        guard let currentViewController = viewControllers?.first,
            let previousViewController = pageViewController(self, viewControllerBefore: currentViewController) else {
                return
        }
        
        setViewControllers([previousViewController], direction: .reverse, animated: true)
    }
    
    @objc private func didSelectCategory(notification: NSNotification) {
        guard let category = notification.object as? PresetCategory else {
            return
        }
        
        selectedCategory = category
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
