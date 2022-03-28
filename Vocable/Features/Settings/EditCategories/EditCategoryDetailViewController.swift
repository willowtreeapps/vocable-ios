//
//  EditCategoryDetailViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

final class EditCategoryDetailViewController: VocableCollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, EditCategoryItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, EditCategoryItem>
    private typealias CellRegistration = UICollectionView.CellRegistration<VocableListCell, EditCategoryItem>

    private enum Section: Int, CaseIterable {
        case body
        case footer
    }

    private enum EditCategoryItem: Int {
        case renameCategory
        case showCategoryToggle
        case addPhrase
        case removeCategory
    }

    let category: Category

    private let context = NSPersistentContainer.shared.viewContext
    private lazy var dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        self?.collectionView(collectionView, cellForItem: item, at: indexPath)
    }

    private var cellRegistration: CellRegistration!

    init(_ category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
    }

    private func setupNavigationBar() {
        navigationBar.title = category.name
        navigationBar.leftButton = {
            let button = GazeableButton()
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            button.addTarget(self, action: #selector(handleBackButton), for: .primaryActionTriggered)
            button.accessibilityIdentifier = "navigationBar.backButton"
            return button
        }()
    }

    // MARK: UICollectionViewDataSource
    
    private func updateDataSource() {
        var snapshot = Snapshot()

        snapshot.appendSections([.body, .footer])
        snapshot.appendItems([.renameCategory, .showCategoryToggle, .addPhrase], toSection: .body)
        snapshot.appendItems([.removeCategory], toSection: .footer)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupCollectionView() {
        collectionView.registerNib(EditCategoryToggleCollectionViewCell.self)
        collectionView.registerNib(EditCategoryRemoveCollectionViewCell.self)
        collectionView.registerNib(SettingsCollectionViewCell.self)
        collectionView.backgroundColor = .collectionViewBackgroundColor

        cellRegistration = CellRegistration { cell, _, _ in
            let config = VocableListContentConfiguration(
                title: "Rename Category",
                accessory: .disclosureIndicator(),
                isPrimaryActionEnabled: true
            ) { [weak self] in
                self?.handleRenameCategory()
            }

            cell.contentConfiguration = config
        }


        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in

            let section = self?.dataSource.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .body:
                return self?.bodySection(environment: environment)
            case .footer:
                return self?.footerSection(environment: environment)
            case .none:
                return nil
            }
        }
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

    private func footerSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

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

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: 0,
                                       leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
                                       bottom: 0,
                                       trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0))
    }

    private func collectionView(
        _ collectionView: UICollectionView,
        cellForItem item: EditCategoryItem,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch item {
        case .renameCategory:
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item)

            return cell
        case .showCategoryToggle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryToggleCollectionViewCell
            cell.isEnabled = shouldEnableItem(at: indexPath)
            cell.textLabel.text = NSLocalizedString("category_editor.detail.button.show_category.title", comment: "Show category button label within the category detail screen.")

            cell.showCategorySwitch.isOn = !category.isHidden
            cell.showCategorySwitch.isEnabled = (category.identifier != .userFavorites)

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
        case .renameCategory:
            handleRenameCategory()
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

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldEnableItem(at: indexPath)
    }

    private func shouldEnableItem(at indexPath: IndexPath) -> Bool {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return false }

        switch selectedItem {
        case .renameCategory:
            return true
        case .showCategoryToggle, .removeCategory:
            return (category.identifier != .userFavorites)
        case .addPhrase:
            return category.allowsCustomPhrases
        }
    }

    // MARK: Actions
    
    @objc func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func handleToggle(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EditCategoryToggleCollectionViewCell else { return }

        let shouldShowCategory = !cell.showCategorySwitch.isOn
        category.setValue(!category.isHidden, forKey: "isHidden")
        cell.showCategorySwitch.isOn = shouldShowCategory
        try? Category.updateAllOrdinalValues(in: context)
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

    func handleRenameCategory() {
        guard let categoryIdentifier = category.identifier else {
            assertionFailure("Category has no identifier")
            return
        }

        let initialValue = category.name ?? ""
        let viewController = EditTextViewController()
        viewController.initialText = initialValue
        viewController.editTextCompletionHandler = { [weak self] newText in
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

                self?.collectionView.reloadData()
                self?.navigationBar.title = newText
            } catch {
                assertionFailure("Failed to save category: \(error)")
            }
        }

        present(viewController, animated: true)
    }
    
}
