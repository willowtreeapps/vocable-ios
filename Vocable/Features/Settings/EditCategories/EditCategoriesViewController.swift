//
//  EditCategoriesViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData

final class EditCategoriesViewController: PagingCarouselViewController, NSFetchedResultsControllerDelegate {

    private var carouselCollectionViewController: CarouselGridCollectionViewController?
    private var disposables = Set<AnyCancellable>()

    private lazy var diffableDataSource = CarouselCollectionViewDataSourceProxy<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let category = self.fetchResultsController.object(at: indexPath)
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

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()

        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        navigationBar.title = NSLocalizedString("categories_list_editor.header.title",
                                                comment: "Categories list editor screen header title")

        navigationBar.leftButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            button.addTarget(self, action: #selector(backToEditCategories), for: .primaryActionTriggered)
            return button
        }()

        navigationBar.rightButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.accessibilityIdentifier = "settingsCategory.addCategoryButton"
            button.addTarget(self, action: #selector(addButtonPressed), for: .primaryActionTriggered)
            return button
        }()
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "EditCategoriesDefaultCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EditCategoriesDefaultCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "EditCategoriesCompactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EditCategoriesCompactCollectionViewCell")
        collectionView.backgroundColor = .collectionViewBackgroundColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateLayoutForCurrentTraitCollection()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.interItemSpacing = 0
        collectionView.layout.numberOfColumns = .fixedCount(1)

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(75))
        case (.compact, .regular):
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(135))
        case (.compact, .compact), (.regular, .compact):
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(75))
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        
        let shouldAnimate = view.window != nil
        self.diffableDataSource.apply(snapshot, animatingDifferences: shouldAnimate, completion: { [weak self] in
            for indexPath in self?.collectionView.indexPathsForVisibleItems ?? [] {
                self?.setupCell(indexPath: indexPath)
            }
            guard let window = self?.view.window as? HeadGazeWindow, let target = window.activeGazeTarget else {
                return
            }
            if let _ = self?.collectionView.indexPath(containing: target) {
                window.cancelActiveGazeTarget()
            }
        })
    }

    private static let rowIndexFormatter = NumberFormatter()
    private func setupCell(indexPath: IndexPath, cell inputCell: EditCategoriesDefaultCollectionViewCell? = nil, category: Category? = nil) {
        guard let cell = inputCell ?? collectionView.cellForItem(at: indexPath) as? EditCategoriesDefaultCollectionViewCell else { return }
        let indexPath = diffableDataSource.indexPath(fromMappedIndexPath: indexPath)
        let category = category ?? fetchResultsController.object(at: indexPath)

        let rowOrdinal = indexPath.row + 1
        let formattedRowOrdinal = EditCategoriesViewController.rowIndexFormatter.string(from: NSNumber(value: rowOrdinal)) ?? "\(rowOrdinal)"
        let visibleTitleString = NSMutableAttributedString(string: "\(formattedRowOrdinal). \(category.name ?? "")")
        cell.showCategoryDetailButton.isEnabled = true
        cell.setup(title: visibleTitleString)

        cell.separatorMask = collectionView.layout.separatorMask(for: indexPath)
        cell.ordinalButtonMask = cellOrdinalButtonMask(for: indexPath)
    }

    @objc private func handleMoveCategoryUp(_ sender: UIButton) {
        guard let _fromIndexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        let fromIndexPath = diffableDataSource.indexPath(fromMappedIndexPath: _fromIndexPath)

        guard let toIndexPath = collectionView.indexPath(before: _fromIndexPath) else {
            assertionFailure("Failed to obtain index before indexPath")
            return
        }

        let fromCategory = fetchResultsController.object(at: fromIndexPath)
        let toCategory = fetchResultsController.object(at: toIndexPath)

        swapOrdinal(fromCategory: fromCategory, toCategory: toCategory)
        saveContext()
    }

    @objc private func handleMoveCategoryDown(_ sender: UIButton) {
        guard let _fromIndexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        let fromIndexPath = diffableDataSource.indexPath(fromMappedIndexPath: _fromIndexPath)

        guard let toIndexPath = collectionView.indexPath(after: fromIndexPath) else {
            assertionFailure("Failed to obtain index before indexPath")
            return
        }
        let fromCategory = fetchResultsController.object(at: fromIndexPath)
        let toCategory = fetchResultsController.object(at: toIndexPath)

        swapOrdinal(fromCategory: fromCategory, toCategory: toCategory)
        saveContext()
    }

    @objc private func handleShowEditCategoryDetail(_ sender: UIButton) {
        guard let _indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        let indexPath = diffableDataSource.indexPath(fromMappedIndexPath: _indexPath)
        let category = fetchResultsController.object(at: indexPath)
        let destination: UIViewController
        if category == Category.listeningModeCategory() {
            destination = ListeningModeViewController()
        } else {
            let viewController = EditCategoryDetailViewController()
            viewController.category = fetchResultsController.object(at: indexPath)
            destination = viewController
        }
        show(destination, sender: nil)
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

    private func cellOrdinalButtonMask(for indexPath: IndexPath) -> CellOrdinalButtonMask {

        let indexPath = diffableDataSource.indexPath(fromMappedIndexPath: indexPath)
        let category = fetchResultsController.object(at: indexPath)

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

    @objc private func backToEditCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func addButtonPressed(_ sender: Any) {
        let viewController = EditTextViewController()
        viewController.editTextCompletionHandler = { (newText) -> Void in
            let context = NSPersistentContainer.shared.viewContext

            _ = Category.create(withUserEntry: newText, in: context)
            do {
                try Category.updateAllOrdinalValues(in: context)
                try context.save()

                let alertMessage = NSLocalizedString("category_editor.toast.successfully_saved.title", comment: "Saved to Categories")

                ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
            } catch {
                assertionFailure("Failed to save category: \(error)")
            }
        }

        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
}
