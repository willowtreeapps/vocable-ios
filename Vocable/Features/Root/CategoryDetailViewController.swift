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

    private var dataSourceProxy: DataSource!

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

        dataSourceProxy = makeDataSource()
        
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

    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            let cell: UICollectionViewCell
            switch item {
            case .persistedPhrase:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath)
            case .addNewPhrase:
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddPhraseCollectionViewCell.reuseIdentifier, for: indexPath)
            }
            self.configureCell(cell, for: item, at: indexPath)
            return cell
        }
    }

    private func configureCell(_ cell: UICollectionViewCell, for item: CategoryItem, at indexPath: IndexPath) {
        switch item {
        case .persistedPhrase(let objectId):
            let cell = cell as? PresetItemCollectionViewCell

            guard let phrase = Phrase.fetchObject(in: self.frc.managedObjectContext, matching: objectId) else { return }
            cell?.textLabel.text = phrase.utterance
            cell?.accessibilityIdentifier = phrase.identifier
        case .addNewPhrase:
            let cell = cell as? AddPhraseCollectionViewCell
            cell?.accessibilityIdentifier = "add_new_phrase"
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        let pageCountBefore = collectionView.layout.pagesPerSection
        let fetchedSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>

        let updatedSnapshot = makeSnapshot(from: fetchedSnapshot)

        if #available(iOS 15, *) {
            dataSourceProxy.apply(updatedSnapshot, animatingDifferences: false)
        } else {
            dataSourceProxy.apply(updatedSnapshot, animatingDifferences: true) { [weak self] in
                guard let self = self, #unavailable(iOS 15) else { return }

                // This is effectively the same iOS 14 fix we have for
                // screens that have been updated for VocableListCell
                let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
                self.dataSourceProxy.performActions(on: visibleIndexPaths) { elements in
                    guard let cell = self.collectionView.cellForItem(at: elements.virtualIndexPath) else { return }
                    self.configureCell(cell, for: elements.itemIdentifier, at: elements.virtualIndexPath)
                }
            }
        }
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
            let context = NSPersistentContainer.shared.newBackgroundContext()

            context.perform { [weak self] in
                guard
                    let self = self,
                    let phrase = Phrase.fetchObject(in: context, matching: objectId),
                    let utterance = phrase.utterance
                else {
                    self?.lastUtterance = nil
                    return
                }

                self.lastUtterance = utterance

                if self.category.identifier != Category.Identifier.recents {
                    phrase.lastSpokenDate = Date()
                    try? context.save()
                }

                // Dispatch to get off the main queue for performance
                DispatchQueue.global(qos: .userInitiated).async {
                    AVSpeechSynthesizer.shared.speak(utterance, language: AppConfig.activePreferredLanguageCode)
                }
            }
        case .addNewPhrase:
            addNewPhraseButtonSelected()
        }

    }

    private func makeSnapshot(from fetchedSnapshot: NSDiffableDataSourceSnapshot<String, NSManagedObjectID>) -> Snapshot {
        var updatedSnapshot = fetchedSnapshot.mapItemIdentifier(CategoryItem.persistedPhrase)

        if category.allowsCustomPhrases, updatedSnapshot.numberOfItems != 0 {
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
            collectionView.backgroundView = EmptyStateView(type: EmptyStateType.phraseCollection, action: { [weak self] in
                self?.addNewPhraseButtonSelected()
            })
        }
    }

    private func removeEmptyStateIfNeeded() {
        paginationView.isHidden = false
        collectionView.backgroundView = nil
    }

    @IBAction func addNewPhraseButtonSelected() {
        let vc = TextEditorViewController()
        let context = NSPersistentContainer.shared.newBackgroundContext()
        vc.delegate = PhraseEditorConfigurationProvider(categoryIdentifier: category.objectID, context: context)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
