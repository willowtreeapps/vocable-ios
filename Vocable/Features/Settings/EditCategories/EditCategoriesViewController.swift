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

    private var cellRegistration: UICollectionView.CellRegistration<VocableListCell, Category>!

    private lazy var diffableDataSource = CarouselCollectionViewDataSourceProxy<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let category = self.fetchResultsController.managedObjectContext.object(with: category) as! Category
        return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration,
                                                            for: indexPath,
                                                            item: category)
    }

    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = {
            var predicate = !Predicate(\Category.isUserRemoved)
            if !AppConfig.isListenModeEnabled {
                predicate &= !Predicate(\Category.identifier, equalTo: Category.Identifier.listeningMode)
            }
            return predicate
        }()
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

        setupNavigationBar()
        setupCollectionView()

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
    }

    private func setupNavigationBar() {
        navigationBar.title = NSLocalizedString("categories_list_editor.header.title",
                                                comment: "Categories list editor screen header title")

        navigationBar.leftButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            button.addTarget(self, action: #selector(backToEditCategories), for: .primaryActionTriggered)
            button.accessibilityIdentifier = "navigationBar.backButton"
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
        collectionView.backgroundColor = .collectionViewBackgroundColor
        cellRegistration = UICollectionView.CellRegistration<VocableListCell, Category>(handler: { [weak self] cell, indexPath, category in
            self?.updateContentConfiguration(for: cell, at: indexPath, category: category)
        })
    }

    private func updateContentConfiguration(for cell: VocableListCell, at indexPath: IndexPath, category: Category) {
        let categoryID = category.objectID

        let upAction = VocableListCellAction.reorderUp(isEnabled: category.canMoveToLowerOrdinal) { [weak self] in
            self?.handleMoveUpForCategory(withObjectID: categoryID)
        }

        let downAction = VocableListCellAction.reorderDown(isEnabled: category.canMoveToHigherOrdinal) { [weak self] in
            self?.handleMoveDownForCategory(withObjectID: categoryID)
        }

        var config = VocableListContentConfiguration(title: category.name ?? "",
                                                     actions: [upAction, downAction],
                                                     accessory: .disclosureIndicator(),
                                                     accessibilityIdentifier: "edit_category_button") { [weak self] in
            self?.showEditForCategory(withObjectID: categoryID)
        }

        config.traitCollectionChangeHandler = { (traitCollection, newConfig) in
            if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
                newConfig.actionsConfiguration.position = .bottom
            } else {
                newConfig.actionsConfiguration.position = .leading
            }
            if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
                newConfig.actionsConfiguration.size.widthDimension = .fractionalHeight(1.6)
            } else {
                newConfig.actionsConfiguration.size.widthDimension = .fractionalHeight(1.0)
            }
        }

        cell.contentConfiguration = config
        cell.accessibilityIdentifier = category.identifier
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.numberOfColumns = .fixedCount(1)

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            collectionView.layout.interItemSpacing = .uniform(8)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(75))
        case (.compact, .regular):
            collectionView.layout.interItemSpacing = .uniform(32)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(108), maxHeight: .absolute(108))
        case (.compact, .compact), (.regular, .compact):
            collectionView.layout.interItemSpacing = .uniform(8)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(50))
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
            guard let self = self else { return }

            // Workaround for diffable datasource not auto-reconfiguring on iOS 14
            if #unavailable(iOS 15) {
                self.updateVisibleCellConfigurations()
            }

            guard let window = self.view.window as? HeadGazeWindow, let target = window.activeGazeTarget else {
                return
            }
            if let _ = self.collectionView.indexPath(containing: target) {
                window.cancelActiveGazeTarget()
            }
        })
    }

    @available(iOS, obsoleted: 15, message: "Use snapshot-based reconfiguring instead")
    private func updateVisibleCellConfigurations() {
        for indexPath in self.collectionView.indexPathsForVisibleItems {
            if let cell = self.collectionView.cellForItem(at: indexPath) as? VocableListCell {
                guard let categoryID = self.diffableDataSource.itemIdentifier(for: indexPath) else {
                    continue
                }
                let category = self.fetchResultsController.managedObjectContext.object(with: categoryID) as! Category
                self.updateContentConfiguration(for: cell, at: indexPath, category: category)
            }
        }
    }

    private func mappedIndexPathForCategory(withObjectID objectID: NSManagedObjectID) -> IndexPath? {
        guard let category = fetchResultsController.managedObjectContext.object(with: objectID) as? Category else {
            return nil
        }

        guard let standardIndexPath = fetchResultsController.indexPath(forObject: category) else {
            assertionFailure("Failed to obtain index path")
            return nil
        }

        return diffableDataSource.indexPath(fromMappedIndexPath: standardIndexPath)
    }

    private func handleMoveUpForCategory(withObjectID objectID: NSManagedObjectID) {

        guard let fromIndexPath = mappedIndexPathForCategory(withObjectID: objectID) else {
            return
        }
        guard let toIndexPath = collectionView.indexPath(before: fromIndexPath) else {
            return
        }

        let fromCategory = fetchResultsController.object(at: fromIndexPath)
        let toCategory = fetchResultsController.object(at: toIndexPath)

        swapOrdinal(fromCategory: fromCategory, toCategory: toCategory)
    }

    private func handleMoveDownForCategory(withObjectID objectID: NSManagedObjectID) {

        guard let fromIndexPath = mappedIndexPathForCategory(withObjectID: objectID) else {
            return
        }
        guard let toIndexPath = collectionView.indexPath(after: fromIndexPath) else {
            return
        }
        let fromCategory = fetchResultsController.object(at: fromIndexPath)
        let toCategory = fetchResultsController.object(at: toIndexPath)

        swapOrdinal(fromCategory: fromCategory, toCategory: toCategory)
    }

    private func showEditForCategory(withObjectID objectID: NSManagedObjectID) {

        guard let category = fetchResultsController.managedObjectContext.object(with: objectID) as? Category else {
            return
        }

        let destination: UIViewController
        if category == Category.listeningModeCategory() {
            destination = ListeningModeViewController()
        } else {
            destination = EditCategoryDetailViewController(category)
        }
        show(destination, sender: nil)
    }

    private func swapOrdinal(fromCategory: Category, toCategory: Category) {

        let fromCategoryID = fromCategory.objectID
        let toCategoryID = toCategory.objectID

        let context = NSPersistentContainer.shared.newBackgroundContext()
        context.perform {

            guard
                let fromCategory = context.object(with: fromCategoryID) as? Category,
                let toCategory = context.object(with: toCategoryID) as? Category
            else {
                return
            }

            let fromOrdinal = fromCategory.ordinal
            let toOrdinal = toCategory.ordinal

            fromCategory.ordinal = toOrdinal
            toCategory.ordinal = fromOrdinal
            try? Category.updateAllOrdinalValues(in: context)

            do {
                try context.save()
            } catch {
                assertionFailure("Failed to save context: \(error)")
            }
        }
    }

    @objc private func backToEditCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func addButtonPressed(_ sender: Any) {
        let viewController = TextEditorViewController()
        let context = NSPersistentContainer.shared.newBackgroundContext()
        viewController.delegate = CategoryNameEditorConfigurationProvider(context: context)

        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
}
