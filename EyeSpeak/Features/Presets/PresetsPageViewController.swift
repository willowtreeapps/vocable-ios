//
//  PresetsPageViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var selectedItem: String?
    
    private let itemsPerPage = 9
    private var selectedCategory: PresetCategory = .category1 // TODO move this default to TextPresets
    
    private lazy var pages: [UIViewController] = TextPresets.presetsByCategory[selectedCategory]?.chunked(into: itemsPerPage).map { presets in
        let collectionViewController = PresetPageCollectionViewController(collectionViewLayout: PresetPageCollectionViewController.CompositionalLayout(with: presets.count))
        collectionViewController.items = presets
        return collectionViewController
        } ?? []
    
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
        guard let category = notification.object as? PresetCategory else {
            return
        }
        
        selectedCategory = category
    }
}
