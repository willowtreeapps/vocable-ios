//
//  CategoryCollectionViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import CoreData
import UIKit

class CategoryCollectionViewController: CarouselGridCollectionViewController, NSFetchedResultsControllerDelegate {
    
    private lazy var dataSourceProxy = CarouselCollectionViewDataSourceProxy<Int, Category>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryItemCollectionViewCell
        cell.setup(title: category.name!)
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSComparisonPredicate(\Category.isHidden, .equalTo, false)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Category>(fetchRequest: self.fetchRequest,
                                                                                 managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                                 sectionNameKeyPath: nil,
                                                                                 cacheName: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        updateDataSource(animated: false)

        super.viewWillAppear(animated)

        if let selectedCategoryID = ItemSelection.selectedCategoryID {
            let category = fetchResultsController.managedObjectContext.object(with: selectedCategoryID)
            let selectedIndexPath = dataSourceProxy.indexPath(for: category as! Category)
            if let selectedIndexPath = selectedIndexPath {
                dataSourceProxy.performActions(on: selectedIndexPath) { (indexPath) in
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToNearestSelectedIndexPath(animated: false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.scrollToNearestSelectedIndexPath(animated: false)
        }, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(CategoryItemCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact)
            ? .collectionViewBackgroundColor : .categoryBackgroundColor
        collectionView.delaysContentTouches = true

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()

        self.clearsSelectionOnViewWillAppear = false
    }

    private func scrollToNearestSelectedIndexPath(animated: Bool = false) {
        let _indexPath: IndexPath? = {
            guard let selectedMappedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
                return nil
            }
            return dataSourceProxy.indexPath(fromMappedIndexPath: selectedMappedIndexPath)
        }()

        if let indexPath = _indexPath {
            if let destination = layout.indexPathForLeftmostCellOfPage(containing: indexPath) {
                collectionView.scrollToItem(at: destination,
                                            at: .left,
                                            animated: animated)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    func updateLayoutForCurrentTraitCollection() {
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            layout.interItemSpacing = 0
            layout.numberOfColumns = 4
            layout.numberOfRows = .fixedCount(1)
        case (.compact, .regular):
            layout.interItemSpacing = 8
            layout.numberOfColumns = 1
            layout.numberOfRows = .fixedCount(1)
        case (.compact, .compact), (.regular, .compact):
            layout.interItemSpacing = 8
            layout.numberOfColumns = 3
            layout.numberOfRows = .fixedCount(1)
        default:
            break
        }
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, Category>()
        snapshot.appendSections([0])
        snapshot.appendItems(content)
        dataSourceProxy.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }

    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mappedIndexPath = dataSourceProxy.indexPath(fromMappedIndexPath: indexPath)

        dataSourceProxy.performActions(on: mappedIndexPath) { (aPath) in
            collectionView.selectItem(at: aPath, animated: true, scrollPosition: [])
        }

        let selectedIndexPaths = Set(collectionView.indexPathsForSelectedItems?.map {
            dataSourceProxy.indexPath(fromMappedIndexPath: $0)
            } ?? [])
        for path in selectedIndexPaths where path != mappedIndexPath {
            dataSourceProxy.performActions(on: path) { (aPath) in
                collectionView.deselectItem(at: aPath, animated: true)
            }
        }

        ItemSelection.selectedCategoryID = fetchResultsController.object(at: mappedIndexPath).objectID
    }

}
