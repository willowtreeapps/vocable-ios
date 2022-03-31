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
        case editCategory
        case editPhrase
        case removeCategory
    }

    private enum EditCategoryItem: Int {
        case renameCategory
        case showCategoryToggle
        case editPhrases
        case removeCategory
    }

    let category: Category

    private let context = NSPersistentContainer.shared.viewContext
    private var dataSource: DataSource?

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
        setUpDataSource()
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

    private func setUpDataSource() {
        let cellRegistration = makeCellRegistration()

        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    private func updateDataSource() {
        var snapshot = Snapshot()

        snapshot.appendSections([.editCategory, .editPhrase, .removeCategory])
        snapshot.appendItems([.renameCategory, .showCategoryToggle], toSection: .editCategory)
        snapshot.appendItems([.editPhrases], toSection: .editPhrase)
        snapshot.appendItems([.removeCategory], toSection: .removeCategory)

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func makeCellRegistration() -> CellRegistration {
        CellRegistration { [category] cell, indexPath, item in
            var config: VocableListContentConfiguration

            switch item {
            case .renameCategory:
                config = .disclosureCellConfiguration(
                    withTitle: NSLocalizedString(
                        "category_editor.detail.button.rename_category.title",
                        comment: "Rename Category button label within the category detail screen")
                ) { [weak self] in
                    self?.handleRenameCategory()
                }
            case .showCategoryToggle:
                config = .toggleCellConfiguration(
                    withTitle: NSLocalizedString(
                        "category_editor.detail.button.show_category.title",
                        comment: "Show category button label within the category detail screen."),
                    isOn: !category.isHidden
                ) { [weak self] in
                    self?.handleToggle(at: indexPath)
                }

                config.isPrimaryActionEnabled = category.identifier != .userFavorites
                config.accessibilityIdentifier = "show_category_toggle"
            case .editPhrases:
                config = .disclosureCellConfiguration(
                    withTitle: NSLocalizedString(
                        "category_editor.detail.button.edit_phrases.title",
                        comment: "Edit Phrases button label within the category detail screen")
                ) { [weak self] in
                    self?.displayEditPhrasesViewController()
                }

                config.isPrimaryActionEnabled = category.allowsCustomPhrases
                config.accessibilityIdentifier = "edit_phrases_cell"
            case .removeCategory:
                config = .init(attributedText: .removeCategoryTitle) { [weak self] in
                    self?.handleRemoveCategory()
                }

                config.isPrimaryActionEnabled = category.identifier != .userFavorites
                config.accessibilityIdentifier = "remove_category_cell"
                config.primaryBackgroundColor = .errorRed
                config.primaryContentHorizontalAlignment = .center
                config.traitCollectionChangeHandler = { _, updatedConfig in
                    updatedConfig.attributedTitle = .removeCategoryTitle
                }
            }

            cell.contentConfiguration = config
        }
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.delaysContentTouches = false

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in

            let section = self?.dataSource?.snapshot().sectionIdentifiers[sectionIndex]

            switch section {
            case .editCategory:
                return self?.topSection(environment: environment)
            case .editPhrase, .removeCategory:
                return self?.defaultSection(environment: environment)
            case .none:
                return nil
            }
        }
    }

    private func defaultSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = topSection(environment: environment)
        section.contentInsets.top += (sizeClass == .hCompact_vRegular) ? 32 : 16
        return section
    }

    private func topSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemHeightDimension: NSCollectionLayoutDimension
        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let columnCount: Int

        if sizeClass.contains(any: .compact) {
            itemHeightDimension = .absolute(50)
        } else {
            itemHeightDimension = .absolute(100)
        }

        if sizeClass == .hCompact_vRegular {
            columnCount = 1
        } else {
            columnCount = 2
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
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

    // MARK: Actions
    
    @objc private func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func handleToggle(at indexPath: IndexPath) {
        let shouldShowCategory = !category.isHidden
        category.setValue(!category.isHidden, forKey: "isHidden")

        try? Category.updateAllOrdinalValues(in: context)
        saveContext()

        if category == Category.listeningModeCategory() {
            AppConfig.isListeningModeEnabled = shouldShowCategory
        }

        // Update the cell's config

        guard let cell = collectionView.cellForItem(at: indexPath),
              var config = cell.contentConfiguration as? VocableListContentConfiguration,
              case .toggle(let isOn) = config.accessory?.content else {
            return
        }

        config.accessory = .toggle(isOn: !isOn)
        cell.contentConfiguration = config
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
        let alert: GazeableAlertViewController = .removeCategoryAlert { [weak self] in
            self?.removeCategory()
        } cancelAction: { [weak self] in
            self?.deselectCell()
        }

        present(alert, animated: true)
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

private extension GazeableAlertViewController {
    static func removeCategoryAlert(
        removeAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> GazeableAlertViewController {
        let title = NSLocalizedString("category_editor.alert.delete_category_confirmation.title", comment: "Remove category alert title")
        let confirmButtonTitle = NSLocalizedString("category_editor.alert.delete_category_confirmation.button.remove.title", comment: "Remove category alert action title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.delete_category_confirmation.button.cancel.title", comment: "Cancel alert action title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle, handler: cancelAction))
        alert.addAction(GazeableAlertAction(title: confirmButtonTitle, style: .destructive, handler: removeAction))

        return alert
    }
}

private extension NSAttributedString {
    static var removeCategoryTitle: NSAttributedString {
        let isRightToLeftLayout = UITraitCollection.current.layoutDirection == .rightToLeft

        let buttonText = NSLocalizedString("category_editor.detail.button.remove_category.title", comment: "Remove category button label within the category detail screen.")

        let formatString: String  = isRightToLeftLayout ?
            .localizedStringWithFormat("%@ ", buttonText) :
            .localizedStringWithFormat(" %@", buttonText)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        let text = NSMutableAttributedString(string: formatString, attributes: attributes)
        let attachment = NSMutableAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "trash")!))
        attachment.addAttributes(attributes, range: .entireRange(of: attachment.string))

        let textRange = NSRange(of: text.string)
        let insertionIndex = isRightToLeftLayout ? textRange.upperBound : textRange.lowerBound

        text.insert(attachment, at: insertionIndex)

        return text
    }
}
