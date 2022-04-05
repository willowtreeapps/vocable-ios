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

    private func setupNavigationBar() {
        navigationBar.title = category.name
        navigationBar.rightButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.accessibilityIdentifier = "settingsCategory.addPhraseButton"
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

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(130))
        case (.compact, .regular):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(130))
        case (.compact, .compact), (.regular, .compact):
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .fixedCount(2)
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
            collectionView.scrollToMiddleSection(animated: true)
        }
    }

    private func installEmptyStateIfNeeded() {
        guard collectionView.backgroundView == nil else { return }
        paginationView.isHidden = true
        collectionView.backgroundView = EmptyStateView(type: EmptyStateType.phraseCollection, action: addPhrasePressed)
    }

    private func removeEmptyStateIfNeeded() {
        paginationView.isHidden = false
        collectionView.backgroundView = nil
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

        let title = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.title",
                                      comment: "Delete phrase confirmation alert title")
        let deleteButtonTitle = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.button.delete.title",
                                                  comment: "Delete phrase alert action button title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.button.cancel.title",
                                                  comment: "Delete phrase alert cancel button title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle, accessibilityIdentifier: "alert.button.cancel"))
        alert.addAction(GazeableAlertAction(title: deleteButtonTitle, accessibilityIdentifier: "alert.button.delete", style: .destructive, handler: deleteAction))
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

        let title = NSLocalizedString("phrase_editor.alert.cancel_editing_confirmation.title",
                                      comment: "Exit edit sayings alert title")
        let discardButtonTitle = NSLocalizedString("phrase_editor.alert.cancel_editing_confirmation.button.discard.title",
                                                   comment: "Discard changes alert action title")
        let continueButtonTitle = NSLocalizedString("phrase_editor.alert.cancel_editing_confirmation.button.continue_editing.title",
                                                    comment: "Continue editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: continueButtonTitle, accessibilityIdentifier: "alert.button.continue_editing"))
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, accessibilityIdentifier: "alert.button.discard_changes", style: .destructive, handler: discardChangesAction))
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
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white,
                                                             .font: UIFont.systemFont(ofSize: 22, weight: .bold)]

            let attributedText = NSAttributedString(string: phrase.utterance ?? "", attributes: attributes)
            let phraseIdentifier = phrase.objectID

            let deleteAction = VocableListCellAction.delete { [weak self] in
                self?.presentDeletionPromptForPhrase(with: phraseIdentifier)
            }

            cell.contentConfiguration = VocableListContentConfiguration(attributedText: attributedText,
                                                                        actions: [deleteAction],
                                                                        accessory: .disclosureIndicator()) { [weak self] in
                self?.presentEditorForPhrase(with: phraseIdentifier)
            }
        }
    }
}
