//
//  PresetsPageViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

protocol PageIndicatorDelegate: AnyObject {
    func updatePageIndicator(with: String)
}

class PresetsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var pageIndicatorDelegate: PageIndicatorDelegate?
    var selectedItem: PhraseViewModel?
    
    private let itemsPerPage = 9
    private var selectedCategory: CategoryViewModel
    
    private lazy var pages: [UIViewController] = {
        presetViewModels.chunked(into: itemsPerPage).map { viewModels in
            let collectionViewController = PresetPageCollectionViewController(collectionViewLayout: PresetPageCollectionViewController.CompositionalLayout(with: viewModels.count))
            collectionViewController.items = viewModels
            return collectionViewController
            }
    }()
    
    private lazy var presetViewModels: [PhraseViewModel] =
        Category.fetchObject(in: NSPersistentContainer.shared.viewContext,
                             matching: selectedCategory.identifier)?.phrases?
            .compactMap { PhraseViewModel($0 as? Phrase) }
            .sorted { $0.creationDate < $1.creationDate }
            ?? []
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notifyPageIndicatorDelegate()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
        notifyPageIndicatorDelegate()
    }
    
    private func notifyPageIndicatorDelegate() {
        guard let visibleViewController = viewControllers?.first,
            let currentPage = pages.firstIndex(of: visibleViewController) else {
            return
        }
        
        pageIndicatorDelegate?.updatePageIndicator(with: "Page \(currentPage + 1) of \(pages.count)")
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard pages.count > 1,
            let index = pages.firstIndex(of: viewController) else {
                return nil
        }
        
        return pages[safe: index - 1] ?? pages.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard pages.count > 1,
            let index = pages.firstIndex(of: viewController) else {
                return nil
        }
        
        return pages[safe: index + 1] ?? pages.first
    }
    
    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        
        notifyPageIndicatorDelegate()
    }
}
