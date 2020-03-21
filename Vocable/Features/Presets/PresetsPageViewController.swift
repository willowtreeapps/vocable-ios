//
//  PresetsPageViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData
import Combine

class PresetsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var selectedItem: PhraseViewModel?
    
    private var itemsPerPage: Int {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular), (.regular, .compact):
            return 9
        case (.compact, .regular):
            return 8
        default:
            return 6
        }
    }

    private lazy var pages: [UIViewController] = {
        presetViewModels.chunked(into: itemsPerPage).map { viewModels in
            let collectionViewController = PresetPageCollectionViewController(collectionViewLayout: PresetPageCollectionViewController.CompositionalLayout(traitCollection: traitCollection))
            collectionViewController.items = viewModels
            return collectionViewController
        }
    }()
    
    private var presetViewModels: [PhraseViewModel] =
        Category.fetchObject(in: NSPersistentContainer.shared.viewContext,
                             matching: ItemSelection.categoryValueSubject.value.identifier)?.phrases?
            .compactMap { PhraseViewModel($0 as? Phrase) }
            .sorted { $0.creationDate > $1.creationDate }
            ?? []

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
        notifyPageIndicatorSubscribers()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
        notifyPageIndicatorSubscribers()
    }
    
    private func notifyPageIndicatorSubscribers() {
        guard let visibleViewController = viewControllers?.first,
            let currentPage = pages.firstIndex(of: visibleViewController) else {
            return
        }

        ItemSelection.presetsPageIndicatorText = String(format: NSLocalizedString("Page %d of %d", comment: "Pagination Control: page 1 of x"), currentPage + 1, pages.count)
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
        
        notifyPageIndicatorSubscribers()
    }
}
