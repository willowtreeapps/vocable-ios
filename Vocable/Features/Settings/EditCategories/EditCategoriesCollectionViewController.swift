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
    
    private lazy var categoryViewModels: [CategoryViewModel] =
    Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                      sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
        .compactMap { CategoryViewModel($0) }

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, CategoryViewModel>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        var cell = EditCategoriesDefaultCollectionViewCell()
        if self.traitCollection.horizontalSizeClass == .compact && self.traitCollection.verticalSizeClass == .regular {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditCategoriesCompactCollectionViewCell", for: indexPath) as! EditCategoriesDefaultCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoriesDefaultCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoriesDefaultCollectionViewCell
            
            cell.topSeparator.isHidden = !self.layout.separatorMask(for: indexPath).contains(.top)
            cell.bottomSeparator.isHidden = !self.layout.separatorMask(for: indexPath).contains(.bottom)
        }
        
        cell.setup(title: "\(indexPath.row + 1). \(self.categoryViewModels[indexPath.row].name)")
        
        cell.moveUpButton.addTarget(self, action: #selector(self.handleMoveCategoryUp(_:)), for: .primaryActionTriggered)
        cell.moveUpButton.isEnabled = self.setUpButtonEnabled(indexPath: indexPath)
        
        cell.moveDownButton.addTarget(self, action: #selector(self.handleMoveCategoryDown(_:)), for: .primaryActionTriggered)
        cell.moveDownButton.isEnabled = self.setDownButtonEnabled(indexPath: indexPath)
        
        cell.showCategoryDetailButton.addTarget(self, action: #selector(self.handleShowEditCategoryDetail(_:)), for: .primaryActionTriggered)
        
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
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

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true, completion: { [weak self] in
            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false,
                                               animateIfNeeded: true)
        })
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, CategoryViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(categoryViewModels)
        diffableDataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }

    @objc private func handleMoveCategoryUp(_ sender: UIButton) {
        // TODO
    }
    
    @objc private func handleMoveCategoryDown(_ sender: UIButton) {
        // TODO
    }
    
    @objc private func handleShowEditCategoryDetail(_ sender: UIButton) {
        for cell in collectionView.visibleCells where sender.isDescendant(of: cell) {
            
            guard let indexPath = collectionView.indexPath(for: cell) else {
                return
            }
            
            if let vc = UIStoryboard(name: "EditCategories", bundle: nil).instantiateViewController(identifier: "EditCategoryDetail") as? EditCategoryDetailViewController {
                vc.categoryName = categoryViewModels[indexPath.row].name
                show(vc, sender: nil)
            }
        }
    }
}
