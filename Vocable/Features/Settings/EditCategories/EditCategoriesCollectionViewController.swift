//
//  EditCategoriesCollectionViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EditCategoriesCollectionViewController: CarouselGridCollectionViewController, NSFetchedResultsControllerDelegate {
    
<<<<<<< HEAD
    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, Category>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        let cell: EditCategoriesDefaultCollectionViewCell
=======
    private lazy var categoryViewModels: [CategoryViewModel] =
    Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                      sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
        .compactMap { CategoryViewModel($0) }

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, CategoryViewModel>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        var cell = EditCategoriesDefaultCollectionViewCell()
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
        if self.traitCollection.horizontalSizeClass == .compact && self.traitCollection.verticalSizeClass == .regular {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCategoriesCompactCollectionViewCell", for: indexPath) as! EditCategoriesDefaultCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoriesDefaultCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoriesDefaultCollectionViewCell
<<<<<<< HEAD
        }
        
        self.setupCell(indexPath: indexPath, cell: cell, category: category)
        
        cell.moveUpButton.addTarget(self, action: #selector(self.handleMoveCategoryUp(_:)), for: .primaryActionTriggered)
        
        cell.moveDownButton.addTarget(self, action: #selector(self.handleMoveCategoryDown(_:)), for: .primaryActionTriggered)
=======
            
            cell.topSeparator.isHidden = !self.layout.separatorMask(for: indexPath).contains(.top)
            cell.bottomSeparator.isHidden = !self.layout.separatorMask(for: indexPath).contains(.bottom)
        }
        
        cell.setup(title: "\(indexPath.row + 1). \(self.categoryViewModels[indexPath.row].name)")
        
        cell.moveUpButton.addTarget(self, action: #selector(self.handleMoveCategoryUp(_:)), for: .primaryActionTriggered)
        cell.moveUpButton.isEnabled = self.setUpButtonEnabled(indexPath: indexPath)
        
        cell.moveDownButton.addTarget(self, action: #selector(self.handleMoveCategoryDown(_:)), for: .primaryActionTriggered)
        cell.moveDownButton.isEnabled = self.setDownButtonEnabled(indexPath: indexPath)
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
        
        cell.showCategoryDetailButton.addTarget(self, action: #selector(self.handleShowEditCategoryDetail(_:)), for: .primaryActionTriggered)
        
        return cell
    }

<<<<<<< HEAD
    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        return request
    }()
    

    private lazy var fetchResultsController = NSFetchedResultsController<Category>(fetchRequest: self.fetchRequest,
=======
    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
                                                                                 managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                                 sectionNameKeyPath: nil,
                                                                                 cacheName: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "EditCategoriesDefaultCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "EditCategoriesDefaultCollectionViewCell")
        collectionView.register(UINib(nibName: "EditCategoriesCompactCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "EditCategoriesCompactCollectionViewCell")
        collectionView.backgroundColor = .collectionViewBackgroundColor

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        updateDataSource(animated: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func setUpButtonEnabled(indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    private func setDownButtonEnabled(indexPath: IndexPath) -> Bool {
        if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            return false
        } else {
            return true
        }
    }

    private func updateLayoutForCurrentTraitCollection() {
        layout.interItemSpacing = 0

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            layout.numberOfColumns = 1
            layout.numberOfRows = .minimumHeight(75)
        case (.compact, .regular):
            layout.numberOfColumns = 1
            layout.numberOfRows = .minimumHeight(135)
        case (.compact, .compact), (.regular, .compact):
            layout.numberOfColumns = 1
            layout.numberOfRows = .minimumHeight(75)
        default:
            break
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
<<<<<<< HEAD
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true, completion: { [weak self] in
            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false,
                                               animateIfNeeded: true)
        })
    }
<<<<<<< HEAD
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard [.move, .update].contains(type) else { return }
        
        updateDataSource(animated: true)
        
        if let newIndexPath = newIndexPath {
            setupCell(indexPath: newIndexPath)
        }
        if let oldIndexPath = indexPath {
            setupCell(indexPath: oldIndexPath)
        }
    }
    
    func setupCell(indexPath: IndexPath, cell inputCell: EditCategoriesDefaultCollectionViewCell? = nil, category: Category? = nil) {
        let cell: EditCategoriesDefaultCollectionViewCell
        cell = inputCell ?? collectionView.cellForItem(at: indexPath) as! EditCategoriesDefaultCollectionViewCell
        let category = category ?? fetchResultsController.object(at: indexPath)
        cell.moveUpButton.isEnabled = self.setUpButtonEnabled(indexPath: indexPath)
        cell.moveDownButton.isEnabled = self.setDownButtonEnabled(indexPath: indexPath)
        cell.setup(title: "\(indexPath.row + 1). \(category.name ?? "")")
        
        cell.separatorMask = self.layout.separatorMask(for: indexPath)
    }
    
    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, Category>()
        snapshot.appendSections([0])
        snapshot.appendItems(content)
=======

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, CategoryViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(categoryViewModels)
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
        diffableDataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }

    @objc private func handleMoveCategoryUp(_ sender: UIButton) {
<<<<<<< HEAD
        guard let fromIndexPath = indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        guard let toIndexPath = indexPath(before: fromIndexPath) else {
            assertionFailure("Failed to obtain index before indexPath")
            return
        }
        let fromCategory = fetchResultsController.object(at: fromIndexPath)
        let toCategory = fetchResultsController.object(at: toIndexPath)
        
        swapOrdinal(fromCategory: fromCategory, toCategory: toCategory)
        
        saveContext()
        
    }
    
    @objc private func handleMoveCategoryDown(_ sender: UIButton) {
        guard let fromIndexPath = indexPath(containing: sender) else {
                   assertionFailure("Failed to obtain index path")
                   return
               }
               guard let toIndexPath = indexPath(after: fromIndexPath) else {
                   assertionFailure("Failed to obtain index before indexPath")
                   return
               }
               let fromCategory = fetchResultsController.object(at: fromIndexPath)
               let toCategory = fetchResultsController.object(at: toIndexPath)
               
               swapOrdinal(fromCategory: fromCategory, toCategory: toCategory)
               
               saveContext()
        
=======
        // TODO
    }
    
    @objc private func handleMoveCategoryDown(_ sender: UIButton) {
        // TODO
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
    }
    
    @objc private func handleShowEditCategoryDetail(_ sender: UIButton) {
        for cell in collectionView.visibleCells where sender.isDescendant(of: cell) {
            
            guard let indexPath = collectionView.indexPath(for: cell) else {
                return
            }
            
            if let vc = UIStoryboard(name: "EditCategories", bundle: nil).instantiateViewController(identifier: "EditCategoryDetail") as? EditCategoryDetailViewController {
<<<<<<< HEAD
                
                EditCategoryDetailViewController.category = fetchResultsController.object(at: indexPath)
=======
                vc.categoryName = categoryViewModels[indexPath.row].name
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
                show(vc, sender: nil)
            }
        }
    }
<<<<<<< HEAD
    
    private func indexPath(after indexPath: IndexPath) -> IndexPath? {
        let itemsInSection = collectionView.numberOfItems(inSection: 0)
        let candidateIndex = indexPath.item + 1
        if candidateIndex >= itemsInSection {
            return nil
        } else {
            return IndexPath(row: candidateIndex, section: 0)
        }
    }
    
    private func indexPath(before indexPath: IndexPath) -> IndexPath? {
        let candidateIndex = indexPath.item - 1
        if candidateIndex < 0 {
            return nil
        } else {
            return IndexPath(row: candidateIndex, section: 0)
        }
    }
    
    private func indexPath(containing view: UIView) -> IndexPath? {
        
        for cell in collectionView.visibleCells where view.isDescendant(of: cell) {
            if let indexPath = collectionView.indexPath(for: cell) {
                return indexPath
            }
        }
        return nil
    }
    
    private func swapOrdinal(fromCategory: Category, toCategory: Category) {
        let fromOrdinal = fromCategory.ordinal
        let toOrdinal = toCategory.ordinal
        
        fromCategory.ordinal = toOrdinal
        toCategory.ordinal = fromOrdinal
    }
    
    private func saveContext() {
        do {
            try fetchResultsController.managedObjectContext.save()
        } catch {
            assertionFailure("Failed to move category: \(error)")
        }
    }
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
}
