//
//  CategoryDetailViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 5/1/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import CoreData
import AVFoundation

class CategoryDetailViewController: PagingCarouselViewController, NSFetchedResultsControllerDelegate {
    private typealias DataSource = CarouselCollectionViewDataSourceProxy<String, CategoryItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<String, CategoryItem>

    var category: Category!
    @PublishedValue private(set) var lastUtterance: String?

    private var disposables = Set<AnyCancellable>()

    private enum CategoryItem: Hashable {
        case persistedPhrase(NSManagedObjectID)
        case addNewPhrase
    }

    private lazy var dataSourceProxy = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        guard let self = self else { return nil }

        switch item {
        case .persistedPhrase(let objectId):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as? PresetItemCollectionViewCell

            guard let phrase = Phrase.fetchObject(in: self.frc.managedObjectContext, matching: objectId) else { return cell }
            cell?.textLabel.text = phrase.utterance

            return cell
        case .addNewPhrase:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddPhraseCollectionViewCell.reuseIdentifier, for: indexPath) as? AddPhraseCollectionViewCell

            return cell
        }
    }

    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()

        var predicate = !Predicate(\Phrase.isUserRemoved)
        if category.identifier == Category.Identifier.recents {
            predicate &= Predicate(\Phrase.lastSpokenDate, notEqualTo: nil)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.lastSpokenDate, ascending: false)]
            request.fetchLimit = 9
        } else {
            predicate &= Predicate(\Phrase.category, equalTo: self.category)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        }
        request.predicate = predicate
        return request
    }()

    private lazy var frc = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
                                                              managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)

    convenience init(category: Category) {
        self.init(nibName: nil, bundle: nil)
        self.category = category
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.all.subtracting(.top)
        view.layoutMargins.top = 4

        assert(category != nil, "Category not assigned")

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.register(AddPhraseCollectionViewCell.self, forCellWithReuseIdentifier: AddPhraseCollectionViewCell.reuseIdentifier)
        collectionView.delaysContentTouches = false

        updateLayoutForCurrentTraitCollection()

        frc.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        try? frc.performFetch()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {

        collectionView.layout.interItemSpacing = .uniform(8)
        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(3)
            collectionView.layout.numberOfRows = .flexible(minHeight: .absolute(120))
        case .hCompact_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(2)
            collectionView.layout.numberOfRows = .fixedCount(4)
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.numberOfColumns = .fixedCount(3)
            collectionView.layout.numberOfRows = .fixedCount(2)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        let pageCountBefore = collectionView.layout.pagesPerSection
        let fetchedSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

        let updatedSnapshot = transformFetchedSnapshot(fetchedSnapshot)

        dataSourceProxy.apply(updatedSnapshot, animatingDifferences: false)

        let pageCountAfter = collectionView.layout.pagesPerSection

        if snapshot.itemIdentifiers.isEmpty {
            installEmptyStateIfNeeded()
        } else {
            removeEmptyStateIfNeeded()
        }

        if pageCountBefore < 2, pageCountAfter > 1 {
            collectionView.scrollToMiddleSection(animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath != collectionView.indexPathForGazedItem {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        guard let item = dataSourceProxy.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .persistedPhrase(let objectId):
            guard
                let phrase = Phrase.fetchObject(in: frc.managedObjectContext, matching: objectId),
                let utterance = phrase.utterance
            else {
                lastUtterance = nil
                return
            }

            lastUtterance = utterance

            if category.identifier != Category.Identifier.recents {
                phrase.lastSpokenDate = Date()
                try? frc.managedObjectContext.save()
            }

            // Dispatch to get off the main queue for performance
            DispatchQueue.global(qos: .userInitiated).async {
                AVSpeechSynthesizer.shared.speak(utterance, language: AppConfig.activePreferredLanguageCode)
            }
        case .addNewPhrase:
            addNewPhraseButtonSelected()
        }

    }

    private func transformFetchedSnapshot(_ fetchedSnapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>) -> Snapshot {
        var updatedSnapshot = Snapshot()

        updatedSnapshot.appendSections(fetchedSnapshot.sectionIdentifiers)

        for sectionId in fetchedSnapshot.sectionIdentifiers {
            let categoryItems = fetchedSnapshot.itemIdentifiers(inSection: sectionId).map(CategoryItem.persistedPhrase)

            updatedSnapshot.appendItems(categoryItems, toSection: sectionId)
        }

        if updatedSnapshot.numberOfItems != 0 {
            updatedSnapshot.appendItems([.addNewPhrase])
        }

        return updatedSnapshot
    }

    private func installEmptyStateIfNeeded() {
        guard collectionView.backgroundView == nil else { return }
        paginationView.isHidden = true
        if category.identifier == Category.Identifier.recents {
            collectionView.backgroundView = EmptyStateView(type: EmptyStateType.recents)
        } else {
            collectionView.backgroundView = EmptyStateView(type: EmptyStateType.phraseCollection, action: addNewPhraseButtonSelected)
        }
    }

    private func removeEmptyStateIfNeeded() {
        paginationView.isHidden = false
        collectionView.backgroundView = nil
    }

    @objc private func handleCellDeletionButton(_ sender: UIButton) {

        func deleteAction() {
            self.deletePhrase(sender)
        }

        let title = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.title",
                                      comment: "Delete phrase confirmation alert title")
        let deleteButtonTitle = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.button.delete.title",
                                                  comment: "Delete phrase alert action button title")
        let cancelButtonTitle = NSLocalizedString("category_editor.alert.delete_phrase_confirmation.button.cancel.title",
                                                  comment: "Delete phrase alert cancel button title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(.cancel(withTitle: cancelButtonTitle))
        alert.addAction(.delete(withTitle: deleteButtonTitle, handler: deleteAction))
        self.present(alert, animated: true)
    }

    private func deletePhrase(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }

        let safeIndexPath = dataSourceProxy.indexPath(fromMappedIndexPath: indexPath)
        let phrase = frc.object(at: safeIndexPath)
        let context = NSPersistentContainer.shared.viewContext
        context.delete(phrase)
        try? context.save()
    }

    @IBAction func addNewPhraseButtonSelected() {
        let vc = TextEditorViewController()
        let context = NSPersistentContainer.shared.newBackgroundContext()
        vc.delegate = PhraseEditorConfigurationProvider(categoryIdentifier: category.objectID, context: context)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
