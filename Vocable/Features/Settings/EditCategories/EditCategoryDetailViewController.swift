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

        dataSource = makeDataSource()

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

    private func makeDataSource() -> DataSource {
        let renameCategoryRegistration = makeRenameCategoryCellRegistration()
        let showCategoryRegistration = makeShowCategoryCellRegistration()
        let editPhrasesRegistration = makeEditPhrasesCellRegistration()
        let removeCategoryRegistration = makeRemoveCategoryCellRegistration()

        return DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .renameCategory:
                return collectionView.dequeueConfiguredReusableCell(
                    using: renameCategoryRegistration,
                    for: indexPath,
                    item: item)
            case .showCategoryToggle:
                return collectionView.dequeueConfiguredReusableCell(
                    using: showCategoryRegistration,
                    for: indexPath,
                    item: item)
            case .editPhrases:
                return collectionView.dequeueConfiguredReusableCell(
                    using: editPhrasesRegistration,
                    for: indexPath,
                    item: item)
            case .removeCategory:
                return collectionView.dequeueConfiguredReusableCell(
                    using: removeCategoryRegistration,
                    for: indexPath,
                    item: item)
            }
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

    // MARK: Cell Registrations

    private func makeRenameCategoryCellRegistration() -> CellRegistration {
        CellRegistration { cell, _, item in
            guard item == .renameCategory else {
                return assertionFailure("This cell registration is for the Rename Category cell.")
            }

            var config: VocableListContentConfiguration = .disclosureCellConfiguration(
                withTitle: NSLocalizedString(
                    "category_editor.detail.button.rename_category.title",
                    comment: "Rename Category button label within the category detail screen")
            ) { [weak self] in
                self?.handleRenameCategory()
            }

            config.accessibilityIdentifier = "rename_category_button"

            cell.contentConfiguration = config
        }
    }

    private func makeShowCategoryCellRegistration() -> CellRegistration {
        CellRegistration { [category] cell, indexPath, item in
            guard item == .showCategoryToggle else {
                return assertionFailure("This cell registration is for the Show Category cell.")
            }

            var config: VocableListContentConfiguration = .toggleCellConfiguration(
                withTitle: NSLocalizedString(
                    "category_editor.detail.button.show_category.title",
                    comment: "Show category button label within the category detail screen."),
                isOn: !category.isHidden
            ) { [weak self] in
                self?.handleToggle(at: indexPath)
            }

            config.isPrimaryActionEnabled = category.identifier != .userFavorites
            config.accessibilityIdentifier = "show_category_toggle"

            cell.contentConfiguration = config
        }
    }

    private func makeEditPhrasesCellRegistration() -> CellRegistration {
        CellRegistration { [category] cell, _, item in
            guard item == .editPhrases else {
                return assertionFailure("This cell registration is for the Edit Phrases cell.")
            }

            var config: VocableListContentConfiguration = .disclosureCellConfiguration(
                withTitle: NSLocalizedString(
                    "category_editor.detail.button.edit_phrases.title",
                    comment: "Edit Phrases button label within the category detail screen")
            ) { [weak self] in
                self?.displayEditPhrasesViewController()
            }

            config.isPrimaryActionEnabled = category.allowsCustomPhrases
            config.accessibilityIdentifier = "edit_phrases_cell"

            cell.contentConfiguration = config
        }
    }

    private func makeRemoveCategoryCellRegistration() -> CellRegistration {
        CellRegistration { [category] cell, _, item in
            guard item == .removeCategory else {
                return assertionFailure("This cell registration is for the Remove Category cell.")
            }

            var config: VocableListContentConfiguration = .init(attributedText: .removeCategoryTitle) { [weak self] in
                self?.handleRemoveCategory()
            }

            config.isPrimaryActionEnabled = category.identifier != .userFavorites
            config.accessibilityIdentifier = "remove_category_cell"
            config.primaryBackgroundColor = .errorRed
            config.primaryContentHorizontalAlignment = .center
            config.traitCollectionChangeHandler = { _, updatedConfig in
                updatedConfig.attributedTitle = .removeCategoryTitle
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

    private func reloadData() {
        collectionView.reloadData()
        navigationBar.title = category.name
    }

    // MARK: EditCategoryDetailTitleCollectionViewCellDelegate

    func handleRenameCategory() {
        let context = NSPersistentContainer.shared.newBackgroundContext()
        let viewController = TextEditorViewController()
        viewController.delegate = CategoryNameEditorConfigurationProvider(categoryIdentifier: category.objectID, context: context, didSaveCategory: { [weak self] in
            self?.reloadData()
        })
        present(viewController, animated: true)
    }
}

private extension GazeableAlertViewController {
    static func removeCategoryAlert(
        removeAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> GazeableAlertViewController {
        let title = NSLocalizedString("category_editor.alert.delete_category_confirmation.title", comment: "Remove category alert title")
        let removeButtonTitle = NSLocalizedString("category_editor.alert.delete_category_confirmation.button.remove.title", comment: "Remove category alert action title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.delete_category_confirmation.button.cancel.title", comment: "Cancel alert action title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(.cancel(withTitle: cancelButtonTitle, handler: cancelAction))
        alert.addAction(.delete(withTitle: removeButtonTitle, handler: removeAction))

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
