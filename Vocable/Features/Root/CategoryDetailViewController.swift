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

    var category: Category!
    @PublishedValue private(set) var lastUtterance: String?

    private var disposables = Set<AnyCancellable>()

    private lazy var dataSourceProxy = CarouselCollectionViewDataSourceProxy<String, NSManagedObjectID>(collectionView: collectionView) { [weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let phrase = self.frc.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
        cell.textLabel.text = phrase.utterance
        return cell
    }

    private lazy var fetchRequest: NSFetchRequest<Phrase> = {
        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()

        if category.identifier == Category.Identifier.recents {
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.lastSpokenDate, ascending: false)]
            request.fetchLimit = 9
        } else {
            request.predicate = NSComparisonPredicate(\Phrase.category, .equalTo, self.category)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Phrase.creationDate, ascending: false)]
        }
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
        collectionView.delaysContentTouches = false

        updateLayoutForCurrentTraitCollection()

        frc.delegate = self
        try? frc.performFetch()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {

        collectionView.layout.interItemSpacing = 8
        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = .fixedCount(3)
            collectionView.layout.numberOfRows = .minimumHeight(120)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath != collectionView.indexPathForGazedItem {
            collectionView.deselectItem(at: indexPath, animated: true)
        }

        let path = dataSourceProxy.indexPath(fromMappedIndexPath: indexPath)
        let phrase = frc.object(at: path)
        guard let utterance = phrase.utterance else {
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
    }

    private func installEmptyStateIfNeeded() {
        guard AppConfig.emptyStatesEnabled else { return }
        guard collectionView.backgroundView == nil else { return }
        paginationView.isHidden = true
        if category.identifier == Category.Identifier.recents {
            collectionView.backgroundView = RecentsEmptyStateView()
        } else {
            collectionView.backgroundView = PhraseCollectionEmptyStateView(action: addNewPhraseButtonSelected)
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
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        alert.addAction(GazeableAlertAction(title: deleteButtonTitle, handler: deleteAction))
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

    @objc private func handleCellEditButton(_ sender: UIButton) {
        guard let indexPath = collectionView.indexPath(containing: sender) else {
            assertionFailure("Failed to obtain index path")
            return
        }

        let safeIndexPath = dataSourceProxy.indexPath(fromMappedIndexPath: indexPath)
        let vc = EditTextViewController()

        let phrase = frc.object(at: safeIndexPath)
        vc.initialText = phrase.utterance ?? ""
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
        alert.addAction(GazeableAlertAction(title: continueButtonTitle, style: .bold))
        self.present(alert, animated: true)
    }

    @IBAction func addNewPhraseButtonSelected() {
        let vc = EditTextViewController()
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
}
