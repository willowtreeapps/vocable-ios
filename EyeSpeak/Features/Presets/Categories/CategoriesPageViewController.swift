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
    private lazy var pages: [UIViewController] = PresetCategory.allCases.chunked(into: itemsPerPage).map { categories in
        let collectionViewController = CategoryPageCollectionViewController(collectionViewLayout: CategoryPageCollectionViewController.createLayout(with: categories.count))
        collectionViewController.items = categories
        return collectionViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        setViewControllers([pages.first!], direction: .forward, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        didMove(toParent: <#T##UIViewController?#>)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        return pages[safe: index - 1] ?? pages.last!
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        return pages[safe: index + 1] ?? pages.first!
    }
    
    // MARK: - UIPageViewControllerDelegate
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
