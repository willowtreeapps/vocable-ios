//
//  CategoryCollectionViewController.swift
//  Vocable AAC
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

    private var presentationMode: PresentationMode = .defaultMode {
        didSet {
            guard oldValue != presentationMode else { return }
            self.updateLayoutForCurrentTraitCollection()
        }
    }
    
    private lazy var dataSourceProxy = CarouselCollectionViewDataSourceProxy<Int, PhraseViewModel>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell

        cell.setup(title: phrase.utterance)
        
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
            let category = NSPersistentContainer.shared.viewContext.object(with: selectedCategoryID)
            request.predicate = NSComparisonPredicate(\Phrase.categories, .contains, category)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {

        updateFetchedResultsController(with: categoryID)

        super.viewWillAppear(animated)

        updateDataSource(animated: true)

        layout.$progress.sink { (pagingProgress) in
            ItemSelection.presetsPageIndicatorProgress = pagingProgress
        }.store(in: &disposables)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
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
                layout.numberOfColumns = .fixedCount(3)
                layout.numberOfRows = .fixedCount(3)
            case (.compact, .regular):
                layout.numberOfColumns = .fixedCount(2)
                layout.numberOfRows = .fixedCount(4)
            case (.compact, .compact), (.regular, .compact):
                layout.numberOfColumns = .fixedCount(3)
                layout.numberOfRows = .fixedCount(2)
            default:
                break
            }
        case .numPadMode:
            switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
            case (.regular, .regular):
                layout.numberOfColumns = .fixedCount(3)
                layout.numberOfRows = .fixedCount(4)
            case (.compact, .regular):
                layout.numberOfColumns = .fixedCount(3)
                layout.numberOfRows = .fixedCount(4)
            case (.compact, .compact), (.regular, .compact):
                layout.numberOfColumns = .fixedCount(6)
                layout.numberOfRows = .fixedCount(2)
            default:
                break
            }
        }
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchedResultsController?.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhraseViewModel>()
        snapshot.appendSections([0])
        
        switch presentationMode {
        case .numPadMode:
            let numPadPresets = KeyboardPresets.numPadPhrases
            snapshot.appendItems(numPadPresets)
        case .defaultMode:
            let presets = content.compactMap { (phrase) in
                return PhraseViewModel(phrase)
            }
            snapshot.appendItems(presets)
        }
        
        dataSourceProxy.apply(snapshot,
                              animatingDifferences: animated,
                              completion: completion)

        let category = Category.fetch(.userFavorites, in: fetchedResultsController!.managedObjectContext)
        if content.isEmpty, category.objectID == categoryID {
            installEmptyStateIfNeeded()
        } else {
            removeEmptyStateIfNeeded()
        }
    }

    private func addPhrasePressed() {
        let storyboard = UIStoryboard(name: "EditTextViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "EditTextViewController") as! EditTextViewController
        vc.editTextCompletionHandler = { (newText) -> Void in
            let context = NSPersistentContainer.shared.viewContext

            _ = Phrase.create(withUserEntry: newText, in: context)
            do {
                try context.save()

                let alertMessage: String = {
                    let format = NSLocalizedString("phrase_editor.toast.successfully_saved_to_favorites.title_format", comment: "Saved to user favorites category toast title")
                    let categoryName = Category.userFavoritesCategoryName()
                    return String.localizedStringWithFormat(format, categoryName)
                }()

                ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
            } catch {
                assertionFailure("Failed to save user generated phrase: \(error)")
            }
        }
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func installEmptyStateIfNeeded() {
        guard AppConfig.emptyStatesEnabled else { return }
        guard collectionView.backgroundView == nil else { return }
        collectionView.backgroundView = PhraseCollectionEmptyStateView(action: addPhrasePressed)
    }

    private func removeEmptyStateIfNeeded() {
        collectionView.backgroundView = nil
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

        guard let selectedPhrase = dataSourceProxy.itemIdentifier(for: indexPath) else { return }
        
        ItemSelection.selectedPhrase = selectedPhrase

        // Dispatch to get off the main queue for performance
        DispatchQueue.global(qos: .userInitiated).async {
            AVSpeechSynthesizer.shared.speak(selectedPhrase.utterance, language: AppConfig.activePreferredLanguageCode)
        }
    }

}
