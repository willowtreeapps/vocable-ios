//
//  EditCategoryDetailViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

final class EditCategoryDetailViewController: VocableCollectionViewController, EditCategoryDetailTitleCollectionViewCellDelegate {

    var category: Category!

    private enum Section: Int, CaseIterable {
        case header
        case body
    }

    private enum EditCategoryItem: Int {
        case titleEditView
        case showCategoryToggle
        case addPhrase
        case removeCategory
    }

    private let context = NSPersistentContainer.shared.viewContext
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, EditCategoryItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(category != nil, "Category not provided")

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
    }

    private func setupNavigationBar() {
        navigationBar.leftButton = {
            let button = GazeableButton()
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            button.addTarget(self, action: #selector(handleBackButton(_:)), for: .primaryActionTriggered)
            button.accessibilityIdentifier = "navigationBar.backButton"
            return button
        }()
    }

    // MARK: UICollectionViewDataSource
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, EditCategoryItem>()
        snapshot.appendSections([.header])
        snapshot.appendItems([.titleEditView])

        snapshot.appendSections([.body])
        snapshot.appendItems([.showCategoryToggle, .addPhrase, .removeCategory])

        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "EditCategoryDetailsHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EditCategoryDetailTitleCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "EditCategoryToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EditCategoryToggleCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "EditCategoryRemoveCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EditCategoryRemoveCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SettingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .collectionViewBackgroundColor

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in

            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
            switch section {
            case .header:
                return self.headerSection(environment: environment)
            case .body:
                return self.bodySection(environment: environment)
            }
        }
    }

    private func headerSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension = NSCollectionLayoutDimension.absolute(50)
        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 8
        return section
    }

    private func bodySection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)

        if sizeClass.contains(any: .compact) {
            itemHeightDimension = .absolute(50)
        } else {
            itemHeightDimension = .absolute(100)
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 8
        return section
    }

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: 0,
                                       leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
                                       bottom: 0,
                                       trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0))
    }

    private func defaultSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)

        if sizeClass.contains(any: .compact) {
            itemHeightDimension = .absolute(50)
        } else {
            itemHeightDimension = .absolute(100)
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        return section
    }

    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: EditCategoryItem) -> UICollectionViewCell {
        switch item {
        case .titleEditView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryDetailTitleCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryDetailTitleCollectionViewCell
            cell.delegate = self
            cell.textLabel.text = category.name
            cell.editButton.isEnabled = true            
            
            // Assign identifiers for automation
            cell.accessibilityIdentifier = "category_title"
            cell.editButton.accessibilityIdentifier = "category_title_edit_button"

            return cell

        case .showCategoryToggle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryToggleCollectionViewCell
            cell.isEnabled = shouldEnableItem(at: indexPath)
            cell.textLabel.text = NSLocalizedString("category_editor.detail.button.show_category.title", comment: "Show category button label within the category detail screen.")

            if let category = category {
                cell.showCategorySwitch.isOn = !category.isHidden
                cell.showCategorySwitch.isEnabled = (category.identifier != .userFavorites)
            }
            
            // Assign an identifier for automation
            cell.showCategorySwitch.accessibilityIdentifier = "show_category_toggle"
            
            return cell

        case .addPhrase:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsCollectionViewCell
            let title = NSLocalizedString("Edit Phrases", comment: "Edit Phrases")
            cell.setup(title: title, image: UIImage(systemName: "chevron.right"))
            cell.isEnabled = shouldEnableItem(at: indexPath)
            
            // Assign an identifier for automation
            cell.accessibilityIdentifier = "edit_phrases_cell"
            
            return cell

        case .removeCategory:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryRemoveCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryRemoveCollectionViewCell
            cell.isEnabled = shouldEnableItem(at: indexPath)
            cell.textLabel.text = NSLocalizedString("category_editor.detail.button.remove_category.title", comment: "Remove category button label within the category detail screen.")
            
            // Assign an identifier for automation
            cell.accessibilityIdentifier = "remove_category_cell"
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        switch selectedItem {
        case .titleEditView:
            return
        case .showCategoryToggle:
            handleToggle(at: indexPath)
        case .addPhrase:
            displayEditPhrasesViewController()
        case .removeCategory:
            handleRemoveCategory()
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return shouldEnableItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldhi indexPath: IndexPath) -> Bool {
        return shouldEnableItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldEnableItem(at: indexPath)
    }

    private func shouldEnableItem(at indexPath: IndexPath) -> Bool {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return false }

        switch selectedItem {
        case .titleEditView:
            return true
        case .showCategoryToggle, .removeCategory:
            return (category.identifier != .userFavorites)
        case .addPhrase:
            return category.allowsCustomPhrases
        }
    }

    // MARK: Actions
    
    @objc func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func handleBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func handleToggle(at indexPath: IndexPath) {
        guard let category = category, let cell = collectionView.cellForItem(at: indexPath) as? EditCategoryToggleCollectionViewCell else { return }

        let shouldShowCategory = !cell.showCategorySwitch.isOn
        category.setValue(!category.isHidden, forKey: "isHidden")
        cell.showCategorySwitch.isOn = shouldShowCategory
        saveContext()

        if category == Category.listeningModeCategory() {
            AppConfig.isListeningModeEnabled = shouldShowCategory
        }
    }

    private func displayEditPhrasesViewController() {
        let viewController = EditPhrasesViewController()
        viewController.category = category
        show(viewController, sender: nil)
    }

    private func handleDismissAlert() {
        func confirmChangesAction() {
            self.dismiss(animated: true, completion: nil)
        }

        let title = NSLocalizedString("category_editor.alert.cancel_editing_confirmation.title", comment: "Exit edit categories alert title")
        let confirmButtonTitle = NSLocalizedString("category_editor.alert.cancel_editing_confirmation.button.confirm_exit.title", comment: "Confirm exit category alert action title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.cancel_editing_confirmation.button.cancel.title", comment: "Cancel exit editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        alert.addAction(GazeableAlertAction(title: confirmButtonTitle, style: .bold, handler: confirmChangesAction))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func handleRemoveCategory() {
        let title = NSLocalizedString("category_editor.alert.delete_category_confirmation.title", comment: "Remove category alert title")
        let confirmButtonTitle = NSLocalizedString("category_editor.alert.delete_category_confirmation.button.remove.title", comment: "Remove category alert action title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.delete_category_confirmation.button.cancel.title", comment: "Cancel alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: confirmButtonTitle, handler: { self.removeCategory() }))
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle, style: .bold, handler: { self.deselectCell() }))
        self.present(alert, animated: true)
    }
    
    private func removeCategory() {
        guard let category = category else { return }
        if category.isUserGenerated {
            context.delete(category)
        } else {
            category.isUserRemoved = true
        }

        try? Category.updateAllOrdinalValues(in: context)

        if saveContext() {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func deselectCell() {
        for path in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: path, animated: true)
        }
    }

    @discardableResult
    private func saveContext() -> Bool {
        do {
            try context.save()
            return true
        } catch {
            assertionFailure("Failed to unsave user generated phrase: \(error)")
        }
        return false
    }

    // MARK: EditCategoryDetailTitleCollectionViewCellDelegate

    func didTapEdit() {
        guard let categoryIdentifier = category.identifier else {
            assertionFailure("Category has no identifier")
            return
        }

        let initialValue = category.name ?? ""
        let viewController = EditTextViewController()
        viewController.initialText = initialValue
        viewController.editTextCompletionHandler = { (newText) -> Void in
            let context = NSPersistentContainer.shared.viewContext

            if let category = Category.fetchObject(in: context, matching: categoryIdentifier) {
                let textDidChange = (newText != initialValue)
                category.name = newText
                category.isUserRenamed = category.isUserRenamed || textDidChange
            }

            do {
                try Category.updateAllOrdinalValues(in: context)
                try context.save()

                let alertMessage = NSLocalizedString("category_editor.toast.successfully_saved.title",
                                                     comment: "User edited name of the category and saved it successfully")

                ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
                self.collectionView.reloadData()
            } catch {
                assertionFailure("Failed to save category: \(error)")
            }
        }

        present(viewController, animated: true)
    }
    
}
