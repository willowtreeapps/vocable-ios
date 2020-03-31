//
//  EditSayingsCollectionViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/13/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

class EditSayingsCollectionViewController: CarouselGridCollectionViewController, NSFetchedResultsControllerDelegate {

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, PhraseViewModel>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditSayingsCollectionViewCell.reuseIdentifier, for: indexPath) as! EditSayingsCollectionViewCell
        cell.setup(title: phrase.utterance)
        cell.deleteButton.addTarget(self,
                                    action: #selector(self.handleCellDeletionButton(_:)),
                                    for: .primaryActionTriggered)
        cell.editButton.addTarget(self,
                                  action: #selector(self.handleCellEditButton(_:)),
                                  for: .primaryActionTriggered)
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = NSComparisonPredicate(\Phrase.isUserGenerated, .equalTo, true)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        return request
    }()

    private lazy var fetchResultsController = NSFetchedResultsController<Phrase>(fetchRequest: self.fetchRequest,
                                                                                 managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                                 sectionNameKeyPath: nil,
                                                                                 cacheName: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "EditSayingsCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "EditSayingsCollectionViewCell")
        collectionView.backgroundColor = .collectionViewBackgroundColor

        updateLayoutForCurrentTraitCollection()

        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        updateDataSource(animated: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        layout.interItemSpacing = 8

        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.regular, .regular):
            layout.numberOfColumns = 2
            layout.numberOfRows = 3
        case (.compact, .regular):
            layout.numberOfColumns = 1
            layout.numberOfRows = 3
        case (.compact, .compact), (.regular, .compact):
            layout.numberOfColumns = 1
            layout.numberOfRows = 2
        default:
            break
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true, completion: { [weak self] in
            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false,
                                               animateIfNeeded: true)
        })
    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = fetchResultsController.fetchedObjects ?? []
        let viewModels = content.compactMap(PhraseViewModel.init)
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhraseViewModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModels)
        diffableDataSource.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
    }

    @objc private func handleCellDeletionButton(_ sender: UIButton) {
        let alert = GazeableAlertViewController(alertTitle: NSLocalizedString("Deleted phrases cannot be recovered.", comment: "Delete saying alert title"))
        alert.addAction(GazeableAlertAction(title: NSLocalizedString("Delete", comment: "Delete saying alert action title"), handler: { self.deletePhrase(sender) }))
        alert.addAction(GazeableAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel alert action title")))
        self.present(alert, animated: true)
    }
    
    private func deletePhrase(_ sender: UIButton) {
        for cell in self.collectionView.visibleCells where sender.isDescendant(of: cell) {
            guard let indexPath = self.collectionView.indexPath(for: cell) else {
                return
            }
            let phrase = self.fetchResultsController.object(at: indexPath)
            let context = NSPersistentContainer.shared.viewContext
            context.delete(phrase)
            try? context.save()
        }
    }
    
    @objc private func handleCellEditButton(_ sender: UIButton) {
        for cell in collectionView.visibleCells where sender.isDescendant(of: cell) {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                return
            }
            if let vc = UIStoryboard(name: "EditSayings", bundle: nil).instantiateViewController(identifier: "EditSaying") as? EditSayingsKeyboardViewController {
                let phrase = fetchResultsController.object(at: indexPath)
                vc.phraseIdentifier = phrase.identifier
                show(vc, sender: nil)
                return
            }
        }
    }
}
