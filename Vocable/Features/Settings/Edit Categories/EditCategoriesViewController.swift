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

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, Category>(collectionView: collectionView) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
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

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        updateDataSource(animated: false)

        setupNavigationBar()
        setupCollectionView()
    }

    private func setupNavigationBar() {
        navigationController?.title = NSLocalizedString("categories_list_editor.header.title",
                                                        comment: "Categories list editor screen header title")

        navigationBar.leftButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            button.addTarget(self, action: #selector(backToEditCategories), for: .primaryActionTriggered)
            return button
        }()

        if AppConfig.editPhrasesEnabled {
            navigationBar.rightButton = {
                let button = GazeableButton(frame: .zero)
                button.setImage(UIImage(systemName: "plus"), for: .normal)
                button.addTarget(self, action: #selector(addButtonPressed), for: .primaryActionTriggered)
                return button
            }()
        }
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
        
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .minimumHeight(75)
        case (.compact, .regular):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .minimumHeight(135)
        case (.compact, .compact), (.regular, .compact):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .minimumHeight(75)
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

        cell.separatorMask = collectionView.layout.separatorMask(for: indexPath)
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
        guard let toIndexPath = collectionView.indexPath(before: fromIndexPath) else {
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
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }

        let viewController = UIStoryboard(name: "EditCategoryDetail", bundle: nil).instantiateViewController(identifier: "EditCategoryDetail") as! EditCategoryDetailViewController
        viewController.category = fetchResultsController.object(at: indexPath)
        show(viewController, sender: nil)
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

    @IBAction func backToEditCategories(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "EditTextViewController", bundle: nil).instantiateViewController(identifier: "EditTextViewController") as? EditTextViewController {
            vc.editTextCompletionHandler = { (newText) -> Void in
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
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
}
