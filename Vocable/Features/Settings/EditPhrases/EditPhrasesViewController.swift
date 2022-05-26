//
//  EditPhrasesViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData

final class EditPhrasesViewController: PagingCarouselViewController, NSFetchedResultsControllerDelegate {

    var category: Category!
    private var disposables = Set<AnyCancellable>()

    private lazy var dataSourceProxy = makeDataSourceProxy()

    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = Predicate(\Phrase.category, equalTo: category) && !Predicate(\Phrase.isUserRemoved)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
                                                                                 managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                                 sectionNameKeyPath: nil,
                                                                                 cacheName: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(category != nil, "Category not provided")

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()

        setupNavigationBar()
        setupCollectionView()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        updateBackgroundViewLayoutMargins()
    }

    private func setupNavigationBar() {
        navigationBar.title = category.name
        navigationBar.rightButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.accessibilityID = .settings.editPhrases.addPhraseButton
            button.addTarget(self, action: #selector(addPhrasePressed), for: .primaryActionTriggered)
            return button
        }()
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "EditPhrasesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EditPhrasesCollectionViewCell.reuseIdentifier)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.interItemSpacing = .init(interRowSpacing: 8, interColumnSpacing: 30)

        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(100))
        case .hCompact_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(64))
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(64))
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

        let pageCountBefore = collectionView.layout.pagesPerSection
        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        dataSourceProxy.apply(snapshot, animatingDifferences: false)

        let pageCountAfter = collectionView.layout.pagesPerSection

        if snapshot.itemIdentifiers.isEmpty {
            installEmptyStateIfNeeded()
        } else {
            removeEmptyStateIfNeeded()
        }

        if pageCountBefore < 2, pageCountAfter > 1 {
            collectionView.scrollToMiddleSection(animated: UIView.areAnimationsEnabled)
        }
    }

    private func installEmptyStateIfNeeded() {
        guard collectionView.backgroundView == nil else { return }
        paginationView.isHidden = true
        collectionView.backgroundView = EmptyStateView(type: EmptyStateType.phraseCollection, action: addPhrasePressed)
        updateBackgroundViewLayoutMargins()
    }

    private func removeEmptyStateIfNeeded() {
        paginationView.isHidden = false
        collectionView.backgroundView = nil
    }

    private func updateBackgroundViewLayoutMargins() {
        guard let backgroundView = collectionView.backgroundView else { return }
        backgroundView.directionalLayoutMargins.leading = view.directionalLayoutMargins.leading
        backgroundView.directionalLayoutMargins.trailing = view.directionalLayoutMargins.trailing
    }

    // MARK: Actions
    @IBAction private func addPhrasePressed() {
        let viewController = TextEditorViewController()
        let context = NSPersistentContainer.shared.newBackgroundContext()
        viewController.delegate = PhraseEditorConfigurationProvider(categoryIdentifier: category.objectID,
                                                           context: context)

        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }

    fileprivate func presentDeletionPromptForPhrase(with id: NSManagedObjectID) {

        func deleteAction() {
            self.deletePhrase(with: id)
        }

        let title = String(localized: "category_editor.alert.delete_phrase_confirmation.title")
        let deleteButtonTitle = String(localized: "category_editor.alert.delete_phrase_confirmation.button.delete.title")
        let cancelButtonTitle = String(localized: "category_editor.alert.delete_phrase_confirmation.button.cancel.title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(.cancel(withTitle: cancelButtonTitle))
        alert.addAction(.delete(withTitle: deleteButtonTitle, handler: deleteAction))
        self.present(alert, animated: true)
    }

    private func deletePhrase(with id: NSManagedObjectID) {
        let context = NSPersistentContainer.shared.viewContext
        guard let phrase = context.object(with: id) as? Phrase else { return }

        if phrase.isUserGenerated {
            context.delete(phrase)
        } else {
            phrase.isUserRemoved = true
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Could not save phrase: \(error)")
        }
    }

    fileprivate func presentEditorForPhrase(with id: NSManagedObjectID) {
        let vc = TextEditorViewController()
        let context = NSPersistentContainer.shared.newBackgroundContext()
        vc.delegate = PhraseEditorConfigurationProvider(categoryIdentifier: category.objectID,
                                               phraseIdentifier: id,
                                               context: context)

        present(vc, animated: true)
    }

    private func handleDismissAlert() {

        func discardChangesAction() {
            self.navigationController?.popViewController(animated: true)
        }

        let title = String(localized: "phrase_editor.alert.cancel_editing_confirmation.title")
        let discardButtonTitle = String(localized: "phrase_editor.alert.cancel_editing_confirmation.button.discard.title")
        let continueButtonTitle = String(localized: "phrase_editor.alert.cancel_editing_confirmation.button.continue_editing.title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(.continueEditing(withTitle: continueButtonTitle))
        alert.addAction(.discardChanges(withTitle: discardButtonTitle, handler: discardChangesAction))
        self.present(alert, animated: true)
    }
}

// MARK: - Data Source Proxy
private extension EditPhrasesViewController {

    func makeDataSourceProxy() -> CarouselCollectionViewDataSourceProxy<String, NSManagedObjectID> {
        let cellRegistration = phraseCellRegistration()

        return CarouselCollectionViewDataSourceProxy<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in
            guard let self = self else { return nil }

            let phrase = self.fetchResultsController.object(at: indexPath)
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: phrase)
        }
    }

    func phraseCellRegistration() ->
    UICollectionView.CellRegistration<VocableListCell, Phrase> {
        return .init { cell, _, phrase in
            let phraseIdentifier = phrase.objectID
            
            let deleteAction = VocableListCellAction.delete { [weak self] in
                self?.presentDeletionPromptForPhrase(with: phraseIdentifier)
            }
            let editButtonId = AccessibilityID.settings.editPhrases.editPhraseButton.id
            cell.contentConfiguration = VocableListContentConfiguration(title: phrase.utterance ?? "",
                                                                        actions: [deleteAction],
                                                                        accessory: .disclosureIndicator(),
                                                                        accessibilityIdentifier: editButtonId) { [weak self] in
                self?.presentEditorForPhrase(with: phraseIdentifier)
            }
            cell.accessibilityIdentifier = phrase.identifier
        }
    }
}
