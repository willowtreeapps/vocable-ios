//
//  CategoryCollectionViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import CoreData
import UIKit
import Combine

class PresetCollectionViewController: CarouselGridCollectionViewController, NSFetchedResultsControllerDelegate {
    
    private var disposables = Set<AnyCancellable>()
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Int, Phrase>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
        cell.setup(title: phrase.utterance ?? "")
        return cell
    }

    private var fetchedResultsController: NSFetchedResultsController<Phrase>? {
        didSet {
            oldValue?.delegate = nil
        }
    }
    
    func updateFetchedResultsController(with selectedCategoryID: NSManagedObjectID? = nil) {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        if let selectedCategoryID = selectedCategoryID {
            request.predicate = NSComparisonPredicate(\Phrase.categories, .contains, selectedCategoryID)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController<Phrase>(fetchRequest: request,
                                                                          managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        self.fetchedResultsController = fetchedResultsController
        updateDataSource(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .collectionViewBackgroundColor
        
        _ = ItemSelection.$presetsPageIndicatorProgress.combineLatest(layout.$progress)
        
        updateLayoutForCurrentTraitCollection()
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Phrase>()
        snapshot.appendSections([0])
        dataSource.apply(snapshot,
                                 animatingDifferences: false,
                                 completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ItemSelection.$selectedCategoryID.sink { (selectedCategoryID) in
            DispatchQueue.main.async {
                self.updateFetchedResultsController(with: selectedCategoryID)
            }
        }.store(in: &disposables)
        
        layout.$progress.sink { (pagingProgress) in
            ItemSelection.presetsPageIndicatorProgress = pagingProgress
        }.store(in: &disposables)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    func updateLayoutForCurrentTraitCollection() {
        layout.interItemSpacing = 8

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            layout.numberOfColumns = 3
            layout.numberOfRows = 3
        case (.compact, .regular):
            layout.numberOfColumns = 2
            layout.numberOfRows = 4
        case (.compact, .compact), (.regular, .compact):
            layout.numberOfColumns = 3
            layout.numberOfRows = 2
        default:
            break
        }
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchedResultsController?.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, Phrase>()
        snapshot.appendSections([0])
        snapshot.appendItems(content)
        dataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ItemSelection.selectedPhrase = PhraseViewModel(fetchedResultsController?.object(at: indexPath))
    }

}
