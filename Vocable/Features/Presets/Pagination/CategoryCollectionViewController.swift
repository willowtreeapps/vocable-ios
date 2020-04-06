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
    
    private lazy var categoryViewModels: [CategoryViewModel] =
    Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                      sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
        .compactMap { CategoryViewModel($0) }
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Int, CategoryViewModel>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryItemCollectionViewCell
        cell.setup(title: self.categoryViewModels[indexPath.row].name)
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
                                                                                 managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                                 sectionNameKeyPath: nil,
                                                                                 cacheName: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(CategoryItemCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .categoryBackgroundColor

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        updateDataSource(animated: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    func updateLayoutForCurrentTraitCollection() {
        layout.interItemSpacing = 8

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            layout.numberOfColumns = 4
            layout.numberOfRows = 1
        case (.compact, .regular):
            layout.numberOfColumns = 1
            layout.numberOfRows = 1
        case (.compact, .compact), (.regular, .compact):
            layout.numberOfColumns = 3
            layout.numberOfRows = 1
        default:
            break
        }
    }


    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true, completion: { [weak self] in
            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false,
                                               animateIfNeeded: true)
        })
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        let viewModels = content.compactMap(PhraseViewModel.init)
        var snapshot = NSDiffableDataSourceSnapshot<Int, CategoryViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(categoryViewModels)
        dataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ItemSelection.selectedCategory = categoryViewModels[indexPath.row]
    }

}
