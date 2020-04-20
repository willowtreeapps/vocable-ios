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
import AVFoundation

class PresetCollectionViewController: CarouselGridCollectionViewController, NSFetchedResultsControllerDelegate {

    var categoryID: NSManagedObjectID!

    private var disposables = Set<AnyCancellable>()
    
    private enum PresentationMode {
        case defaultMode
        case numPadMode
    }
    
    private enum ItemWrapper: Hashable {
        case presetsDefault(Phrase)
        case presetsNumPad(PhraseViewModel)
    }
    
    private var presentationMode: PresentationMode = .defaultMode {
        didSet {
            guard oldValue != presentationMode else { return }
            self.updateLayoutForCurrentTraitCollection()
        }
    }
    
    private lazy var dataSourceProxy = CarouselCollectionViewDataSourceProxy<Int, ItemWrapper>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
        
        switch phrase {
        case .presetsDefault(let phrase):
            cell.setup(title: phrase.utterance ?? "")
        case .presetsNumPad(let phraseViewModel):
            cell.setup(title: phraseViewModel.utterance)
        }
        
        return cell
    }

    private var fetchedResultsController: NSFetchedResultsController<Phrase>? {
        didSet {
            oldValue?.delegate = nil
        }
    }
    
    private func updateFetchedResultsController(with selectedCategoryID: NSManagedObjectID? = nil) {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(categoryID != nil, "Expected categoryID provided")

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.delaysContentTouches = true
        
        updateLayoutForCurrentTraitCollection()

        self.updateFetchedResultsController(with: categoryID)

        let selectedCategory = NSPersistentContainer.shared.viewContext.object(with: categoryID) as! Category
        if selectedCategory.identifier == .numPad {
            presentationMode = .numPadMode
        } else {
            presentationMode = .defaultMode
        }
        updateDataSource(animated: true)

        self.scrollToMiddleSection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        layout.$progress.sink { (pagingProgress) in
            ItemSelection.presetsPageIndicatorProgress = pagingProgress
        }.store(in: &disposables)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        layout.interItemSpacing = 8
        
        switch presentationMode {
        case .defaultMode:
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.regular, .regular):
                layout.numberOfColumns = 3
                layout.numberOfRows = .fixedCount(3)
            case (.compact, .regular):
                layout.numberOfColumns = 2
                layout.numberOfRows = .fixedCount(4)
            case (.compact, .compact), (.regular, .compact):
                layout.numberOfColumns = 3
                layout.numberOfRows = .fixedCount(2)
            default:
                break
            }
        case .numPadMode:
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.regular, .regular):
                layout.numberOfColumns = 3
                layout.numberOfRows = .fixedCount(4)
            case (.compact, .regular):
                layout.numberOfColumns = 3
                layout.numberOfRows = .fixedCount(4)
            case (.compact, .compact), (.regular, .compact):
                layout.numberOfColumns = 6
                layout.numberOfRows = .fixedCount(2)
            default:
                break
            }
        }
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchedResultsController?.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, ItemWrapper>()
        snapshot.appendSections([0])
        
        switch presentationMode {
        case .numPadMode:
            let numPadPresets = KeyboardPresets.numPadPhrases.map { (phraseViewModel) in
                return ItemWrapper.presetsNumPad(phraseViewModel)
            }
            snapshot.appendItems(numPadPresets)
        case .defaultMode:
            let presets = content.map { (phrase) in
                return ItemWrapper.presetsDefault(phrase)
            }
            snapshot.appendItems(presets)
        }
        
        dataSourceProxy.apply(snapshot,
                              animatingDifferences: animated,
                              completion: completion)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let indexPath = dataSourceProxy.indexPath(fromMappedIndexPath: indexPath)
        
        for selectedPath in collectionView.indexPathsForSelectedItems ?? [] {
            dataSourceProxy.performActions(on: selectedPath) { aPath in
                if aPath != collectionView.indexPathForGazedItem {
                    collectionView.deselectItem(at: aPath, animated: true)
                }
            }
        }

        guard let identifier = dataSourceProxy.itemIdentifier(for: indexPath) else { return }
        
        let selectedPhrase: PhraseViewModel?
        
        switch identifier {
        case .presetsDefault(let phrase):
            selectedPhrase = PhraseViewModel(phrase)
        case .presetsNumPad(let phraseViewModel):
            selectedPhrase = phraseViewModel
        }
        
        ItemSelection.selectedPhrase = selectedPhrase

        // Dispatch to get off the main queue for performance
        DispatchQueue.global(qos: .userInitiated).async {
            AVSpeechSynthesizer.shared.speak(selectedPhrase?.utterance ?? "", language: AppConfig.activePreferredLanguageCode)
        }
    }

}
