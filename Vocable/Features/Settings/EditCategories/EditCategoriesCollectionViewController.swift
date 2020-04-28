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

final class EditCategoriesCollectionViewController: CarouselGridCollectionViewController, NSFetchedResultsControllerDelegate {
    
    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, Category>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        let cell: EditCategoriesDefaultCollectionViewCell
        if self.traitCollection.horizontalSizeClass == .compact && self.traitCollection.verticalSizeClass == .regular {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCategoriesCompactCollectionViewCell", for: indexPath) as! EditCategoriesDefaultCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoriesDefaultCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoriesDefaultCollectionViewCell
        }
        
        self.setupCell(indexPath: indexPath, cell: cell, category: category)
        
        cell.moveUpButton.addTarget(self, action: #selector(self.handleMoveCategoryUp(_:)), for: .primaryActionTriggered)
        cell.moveDownButton.addTarget(self, action: #selector(self.handleMoveCategoryDown(_:)), for: .primaryActionTriggered)
        cell.showCategoryDetailButton.addTarget(self, action: #selector(self.handleShowEditCategoryDetail(_:)), for: .primaryActionTriggered)
        
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.isHidden, ascending: true),
        NSSortDescriptor(keyPath: \Category.ordinal, ascending: true),
        NSSortDescriptor(keyPath: \Category.creationDate, ascending: true)]
        return request
    }()
    
    private lazy var fetchResultsController = NSFetchedResultsController<Category>(fetchRequest: self.fetchRequest,
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource(animated: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard [.move, .update].contains(type) else { return }

        updateDataSource(animated: true, completion: { [weak self] in
            guard let window = self?.view.window as? HeadGazeWindow, let target = window.activeGazeTarget else {
                    return
            }
            if let _ = self?.collectionView.indexPath(containing: target) {
                window.cancelActiveGazeTarget()
            }
        })
        
        if let newIndexPath = newIndexPath {
            setupCell(indexPath: newIndexPath)
        }
        if let oldIndexPath = indexPath {
            setupCell(indexPath: oldIndexPath)
        }
    }
    
    func setupCell(indexPath: IndexPath, cell inputCell: EditCategoriesDefaultCollectionViewCell? = nil, category: Category? = nil) {
        guard let cell = inputCell ?? collectionView.cellForItem(at: indexPath) as? EditCategoriesDefaultCollectionViewCell else { return }
        let category = category ?? fetchResultsController.object(at: indexPath)
        
        let visibleTitleString = NSMutableAttributedString(string: "\(indexPath.row + 1). \(category.name ?? "")")
        let hiddenTitleString = NSMutableAttributedString(string: "\(category.name ?? "")")
       
        if category.isHidden {
            cell.setup(title: addHiddenIconIfNeeded(to: hiddenTitleString))
        } else {
            cell.setup(title: visibleTitleString)
        }
        cell.separatorMask = self.layout.separatorMask(for: indexPath)
        cell.ordinalButtonMask = cellOrdinalButtonMask(with: category, for: indexPath)
        cell.showCategoryDetailButton.isEnabled = (category.identifier != .userFavorites)
    }
    
    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, Category>()
        snapshot.appendSections([0])
        snapshot.appendItems(content)
        diffableDataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }

    @objc private func handleMoveCategoryUp(_ sender: UIButton) {
        guard let fromIndexPath = collectionView.indexPath(containing: sender) else {
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
        guard let fromIndexPath = collectionView.indexPath(containing: sender) else {
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
        
    }
    
    @objc private func handleShowEditCategoryDetail(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        
        let vc = UIStoryboard(name: "EditCategories", bundle: nil).instantiateViewController(identifier: "EditCategoryDetail") as! EditCategoryDetailViewController
        
        vc.category = fetchResultsController.object(at: indexPath)
        show(vc, sender: nil)
        
    }
    
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
    
    private func addHiddenIconIfNeeded(to titleString: NSMutableAttributedString) -> NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "eye.slash.fill")?.withTintColor(UIColor.white)
        imageAttachment.bounds = CGRect(x: -2, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        titleString.insert(NSAttributedString(string: " "), at: 0)
        titleString.insert(NSAttributedString(attachment: imageAttachment), at: 0)
        return titleString
    }
    
    private func cellOrdinalButtonMask(with category: Category, for indexPath: IndexPath) -> CellOrdinalButtonMask {
        if category.isHidden {
            return .none
        }
        
        //Check if the cell below the current one is hidden, disable down button if needed.
        if indexPath.row + 1 < fetchResultsController.fetchedObjects?.count ?? 0 {
            let nextIndex = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if fetchResultsController.object(at: nextIndex).isHidden {
                return .topUpArrow
            }
        }
        
        if indexPath.row == 0 {
            return .bottomDownArrow
        } else if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            return .topUpArrow
        }
        return .both
    }
}
