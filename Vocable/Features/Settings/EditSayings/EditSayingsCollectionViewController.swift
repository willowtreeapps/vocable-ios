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

    private lazy var diffableDataSource = CarouselCollectionViewDataSourceProxy<Int, PhraseViewModel>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, phrase) -> UICollectionViewCell? in
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
            layout.numberOfRows = .fixedCount(4)
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
        updateDataSource(animated: true)
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

        if viewModels.isEmpty {
            installEmptyStateIfNeeded()
        } else {
            removeEmptyStateIfNeeded()
        }
    }

    private func installEmptyStateIfNeeded() {
        guard collectionView.backgroundView == nil else { return }

        let text = NSLocalizedString("user_favorites_editor.empty_state.title",
                                     comment: "Empty state for edit user favorites screen")

        let starImageAttributedString: NSAttributedString? = {
            guard let image = UIImage(systemName: "star")?.withRenderingMode(.alwaysTemplate) else {
                return nil
            }
            let systemImageAttachment = NSTextAttachment(image: image)
            return NSAttributedString(attachment: systemImageAttachment)
        }()
        let attributedString = NSMutableAttributedString(string: text)
        if let attachmentString = starImageAttributedString {
            attributedString.insert(.init(string: "\n\n"), at: 0)
            attributedString.insert(attachmentString, at: 0)
        }
        let emptyView = EmptyStateView(attributedText: attributedString)
        collectionView.backgroundView = emptyView
    }

    private func removeEmptyStateIfNeeded() {
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
        alert.addAction(GazeableAlertAction(title: deleteButtonTitle, handler: deleteAction))
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        self.present(alert, animated: true)
    }
    
    private func deletePhrase(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        
        let safeIndexPath = diffableDataSource.indexPath(fromMappedIndexPath: indexPath)
        let phrase = self.fetchResultsController.object(at: safeIndexPath)
        let context = NSPersistentContainer.shared.viewContext
        context.delete(phrase)
        try? context.save()
    }
    
    @objc private func handleCellEditButton(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }
        
        let safeIndexPath = diffableDataSource.indexPath(fromMappedIndexPath: indexPath)
        let vc = UIStoryboard(name: "EditTextViewController", bundle: nil)
            .instantiateViewController(identifier: "EditTextViewController") as! EditTextViewController
        vc.modalPresentationStyle = .fullScreen
        
        let phrase = fetchResultsController.object(at: safeIndexPath)
        vc.text = phrase.utterance ?? ""
        vc.editTextCompletionHandler = { (newText) -> Void in
            let context = NSPersistentContainer.shared.viewContext
            
            if let phraseIdentifier = phrase.identifier {
                let originalPhrase = Phrase.fetchObject(in: context, matching: phraseIdentifier)
                originalPhrase?.utterance = newText
            }
            do {
                try context.save()
                
                let alertMessage = NSLocalizedString("category_editor.toast.changes_saved.title",
                                                     comment: "changes to an existing phrase were saved successfully")
                
                ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
            } catch {
                assertionFailure("Failed to save user generated phrase: \(error)")
            }
        }
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
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, handler: discardChangesAction))
        alert.addAction(GazeableAlertAction(title: continueButtonTitle))
        self.present(alert, animated: true)
    }
}
