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
            layout.numberOfRows = .fixedCount(3)
        case (.compact, .regular):
            layout.numberOfColumns = 1
            layout.numberOfRows = .fixedCount(3)
        case (.compact, .compact), (.regular, .compact):
            layout.numberOfColumns = 1
            layout.numberOfRows = .fixedCount(2)
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
        alert.addAction(GazeableAlertAction(title: deleteButtonTitle, handler: deleteAction))
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
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
            if let vc = UIStoryboard(name: "EditTextViewController", bundle: nil).instantiateViewController(identifier: "EditTextViewController") as? EditTextViewController {
                vc.modalPresentationStyle = .fullScreen
                
                let phrase = fetchResultsController.object(at: indexPath)
                vc.text = phrase.utterance ?? ""
                vc.editTextCompletionHandler = { (didChange, newText) -> Void in
                    guard didChange else { return }
                    var isNewPhrase = false
                    let context = NSPersistentContainer.shared.viewContext

                    if let phraseIdentifier = phrase.identifier {
                        let originalPhrase = Phrase.fetchObject(in: context, matching: phraseIdentifier)
                        originalPhrase?.utterance = newText
                    } else {
                        _ = Phrase.create(withUserEntry: newText, in: context)
                        isNewPhrase = true
                    }
                    do {
                        try context.save()

                        let newEntrySavedString: String = {
                            let format = NSLocalizedString("phrase_editor.toast.successfully_saved_to_favorites.title_format", comment: "Saved to user favorites category toast title")
                            let categoryName = Category.userFavoritesCategoryName()
                            return String.localizedStringWithFormat(format, categoryName)
                        }()

                        let changesSavedString = NSLocalizedString("category_editor.toast.changes_saved.title",
                                                                   comment: "changes to an existing phrase were saved successfully")
                        let alertMessage = isNewPhrase ? newEntrySavedString : changesSavedString
                        
                        ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
                    } catch {
                        assertionFailure("Failed to save user generated phrase: \(error)")
                    }
                }
                
                vc.dismissalCompletionHandler = { (newText) -> Bool in
                    let context = NSPersistentContainer.shared.viewContext
                    if let phraseIdentifier = phrase.identifier {
                        let originalPhrase = Phrase.fetchObject(in: context, matching: phraseIdentifier)
                        if originalPhrase?.utterance != newText {
                            self.handleDismissAlert()
                            return false
                        }
                    }
                    return true
                }
                present(vc, animated: true)
            }
        }
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
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, handler: discardChangesAction))
        alert.addAction(GazeableAlertAction(title: continueButtonTitle))
        self.present(alert, animated: true)
    }
}
