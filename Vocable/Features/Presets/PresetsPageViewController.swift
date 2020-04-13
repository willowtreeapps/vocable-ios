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
        var chunked = presetViewModels.chunked(into: itemsPerPage)
        var pageViewControllers: [UIViewController] = []
        
        if ItemSelection.selectedCategory.identifier == TextPresets.numPadIdentifier {
            let numPadCollectionViewController = PresetPageCollectionViewController(collectionViewLayout: PresetPageCollectionViewController.NumPadCompositionalLayout(traitCollection: traitCollection))
            numPadCollectionViewController.items = TextPresets.numPadPhrases
            pageViewControllers.insert(numPadCollectionViewController, at: 0)
        }
        
        if pageViewControllers.isEmpty && chunked.isEmpty {
            chunked.append([]) // Ensure that at least one empty page exists for empty state
        }
        
        let mappedViewControllers = chunked.map { viewModels -> UIViewController in
            let collectionViewController = PresetPageCollectionViewController(collectionViewLayout: PresetPageCollectionViewController.DefaultCompositionalLayout(traitCollection: traitCollection))
            collectionViewController.items = viewModels
            return collectionViewController
        }
        
        pageViewControllers += mappedViewControllers
        return pageViewControllers
    }()
    
    private var presetViewModels: [PhraseViewModel] =
        Category.fetchObject(in: NSPersistentContainer.shared.viewContext,
                             matching: ItemSelection.selectedCategory.identifier)?.phrases?
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
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
        notifyPageIndicatorSubscribers()
    }
    
    private func notifyPageIndicatorSubscribers() {
        guard let visibleViewController = viewControllers?.first,
            let currentPage = pages.firstIndex(of: visibleViewController) else {
                ItemSelection.presetsPageIndicatorProgress = .init(pageIndex: 0, pageCount: 1)
            return
        }
        
        ItemSelection.presetsPageIndicatorProgress = .init(pageIndex: currentPage, pageCount: pages.count)
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
