//
//  CategoriesCarouselViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData
import Speech

@IBDesignable class CategoriesCarouselViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, SpeechRecognizerControllerDelegate {

    static func fetchInitialCategoryID() -> NSManagedObjectID {
        let ctx = NSPersistentContainer.shared.viewContext
        let predicate = NSComparisonPredicate(\Category.isHidden, .equalTo, false)
        let sort = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        let categories = Category.fetchAll(in: ctx,
                          matching: predicate,
                          sortDescriptors: sort)
        return categories[0].objectID
    }

    static func fetchVoiceCategoryID() -> NSManagedObjectID {
        let ctx = NSPersistentContainer.shared.viewContext
        let predicate = NSComparisonPredicate(\Category.identifier, .equalTo, Category.Identifier.voice.rawValue)
        let categories = Category.fetchAll(in: ctx, matching: predicate)
        return categories[0].objectID
    }

    @PublishedValue private(set) var categoryObjectID = fetchInitialCategoryID() {
        didSet {
            categorySelectionDidChange()
        }
    }

    @IBOutlet private weak var backChevron: GazeableButton!
    @IBOutlet private weak var forwardChevron: GazeableButton!
    @IBOutlet private weak var collectionViewContainer: UIView!
    @IBOutlet private weak var collectionView: CarouselGridCollectionView!
    @IBOutlet private weak var outerStackView: UIStackView!

    private lazy var hotWordRecognizer: SpeechRecognizerController = {
        let recognizer = SpeechRecognizerController()
        recognizer.requiredPhrase = "hey vocable"
        recognizer.timeoutInterval = 1.2
        recognizer.delegate = self
        return recognizer
    }()

    private var collectionViewMask = BorderedView(frame: .zero)

    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        var predicate: NSPredicate = NSComparisonPredicate(\Category.isHidden, .equalTo, false)
        if !AppConfig.isVoiceExperimentEnabled {
            let notVoicePredicate = NSComparisonPredicate(\Category.identifier, .notEqualTo, Category.Identifier.voice.rawValue)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, notVoicePredicate])
        }
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        return request
    }()

    private lazy var frc = NSFetchedResultsController<Category>(fetchRequest: self.fetchRequest,
                                                                managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)

    private lazy var dataSourceProxy = CarouselCollectionViewDataSourceProxy<String, NSManagedObjectID>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in
        guard let self = self else { return nil }
        let category = self.frc.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryItemCollectionViewCell
        cell.setup(title: category.name!)
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .collectionViewBackgroundColor

        backChevron.accessibilityIdentifier = "root.categories_carousel.left_chevron"
        forwardChevron.accessibilityIdentifier = "root.categories_carousel.right_chevron"

        collectionViewMask.fillColor = .black
        collectionViewMask.backgroundColor = .clear
        collectionViewContainer.mask = collectionViewMask

        collectionView.register(CategoryItemCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)

        collectionView.delaysContentTouches = true
        collectionView.delegate = self
        for button in [backChevron, forwardChevron] {
            button?.setFillColor(.categoryBackgroundColor, for: .normal)
            button?.cornerRadius = 8
        }

        updateForCurrentTraitCollection()

        frc.delegate = self
        try? frc.performFetch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionViewMaskFrame()
        if AppConfig.isVoiceExperimentEnabled {
            hotWordRecognizer.startListening()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if AppConfig.isVoiceExperimentEnabled {
            hotWordRecognizer.stopListening()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewMaskFrame()
    }

    private func updateCollectionViewMaskFrame() {
        self.collectionViewMask.frame = collectionViewContainer.layoutMarginsGuide.layoutFrame
    }

    private func updateSelectedIndexPathsInProxyDataSource() {

        let objectID: NSManagedObjectID
        if let _ = try? frc.managedObjectContext.existingObject(with: categoryObjectID) as? Category {
            objectID = categoryObjectID
        } else {
            objectID = CategoriesCarouselViewController.fetchInitialCategoryID()
        }

        guard let indexPath = dataSourceProxy.indexPath(for: objectID) else {
            return
        }

        let selectedIndexPaths = Set(collectionView.indexPathsForSelectedItems?.map {
            dataSourceProxy.indexPath(fromMappedIndexPath: $0)
            } ?? [])
        for path in selectedIndexPaths where path != indexPath {
            dataSourceProxy.performActions(on: path) { (aPath) in
                collectionView.deselectItem(at: aPath, animated: true)
            }
        }

        dataSourceProxy.performActions(on: indexPath) { (aPath) in
            collectionView.selectItem(at: aPath, animated: true, scrollPosition: [])
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

        let previousItem: (objectID: NSManagedObjectID, indexPath: IndexPath)? = {
            guard let mapped = collectionView.indexPathsForSelectedItems?.first else {
                return nil
            }
            let indexPath = dataSourceProxy.indexPath(fromMappedIndexPath: mapped)
            guard let objectID = dataSourceProxy.itemIdentifier(for: indexPath) else {
                return nil
            }
            return (objectID: objectID, indexPath: indexPath)
        }()

        let snapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
        dataSourceProxy.apply(snapshot, animatingDifferences: false, completion: {

            guard let previous = previousItem else {
                // No item was previous selected
                self.updateSelectedIndexPathsInProxyDataSource()
                self.collectionView.scrollToNearestSelectedIndexPathOrCurrentPageBoundary(animated: false)
                return
            }

            let newItemIndexPath: IndexPath? = {
                if let indexPath = self.dataSourceProxy.indexPath(for: previous.objectID) {
                    return indexPath
                }
                return self.collectionView.indexPath(nearestTo: previous.indexPath)
            }()

            guard let newPath = newItemIndexPath else {
                // No new path to select
                assertionFailure("New selection index path not found")
                return
            }

            self.collectionView(self.collectionView, didSelectItemAt: newPath)
            self.collectionView.scrollToNearestSelectedIndexPathOrCurrentPageBoundary(animated: true)
        })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateForCurrentTraitCollection(previousTraitCollection: previousTraitCollection)
    }

    private func updateForCurrentTraitCollection(previousTraitCollection: UITraitCollection? = nil) {

        if sizeClass.contains(any: .compact) {
            collectionViewMask.cornerRadius = 8
            collectionView.layout.pageInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
            collectionView.backgroundColor = .collectionViewBackgroundColor
            backChevron.cornerRadius = collectionViewMask.cornerRadius
            forwardChevron.cornerRadius = collectionViewMask.cornerRadius
        } else {
            collectionViewMask.cornerRadius = 8
            collectionView.layout.pageInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
            collectionView.backgroundColor = .categoryBackgroundColor
            backChevron.cornerRadius = collectionViewMask.cornerRadius
            forwardChevron.cornerRadius = collectionViewMask.cornerRadius
        }

        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.interItemSpacing = 0
            collectionView.layout.numberOfColumns = .minimumWidth(216)
            collectionView.layout.numberOfRows = .fixedCount(1)
        case .hCompact_vRegular:
            collectionView.layout.interItemSpacing = 8
            collectionView.layout.numberOfColumns = .fixedCount(1)
            collectionView.layout.numberOfRows = .fixedCount(1)
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.interItemSpacing = 8
            collectionView.layout.numberOfColumns = .fixedCount(3)
            collectionView.layout.numberOfRows = .fixedCount(1)
        default:
            break
        }

    }

    @IBAction private func previousButtonAction(_ sender: Any) {
        collectionView.scrollToPreviousPage()
    }

    @IBAction private func nextButtonAction(_ sender: Any) {
        collectionView.scrollToNextPage()
    }

    private func updateSelectedItemForHorizontallyCompactLayout() {
        guard sizeClass == .hCompact_vRegular, UIView.inheritedAnimationDuration == 0 else { return }
        guard let indexPath = collectionView.indexPathForItem(at: CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY)) else { return }
        if !(collectionView.indexPathsForSelectedItems ?? []).contains(indexPath) {
            collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateCollectionViewMaskFrame()
        })
    }

    private func categorySelectionDidChange() {
        guard AppConfig.isVoiceExperimentEnabled else {
            return
        }
        let voiceID = CategoriesCarouselViewController.fetchVoiceCategoryID()
        if categoryObjectID == voiceID {
            hotWordRecognizer.stopListening()
        } else {
            hotWordRecognizer.startListening()
        }
    }

    // MARK: - UICollectionViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedItemForHorizontallyCompactLayout()
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mappedIndexPath = dataSourceProxy.indexPath(fromMappedIndexPath: indexPath)
        categoryObjectID = frc.object(at: mappedIndexPath).objectID
        updateSelectedIndexPathsInProxyDataSource()
    }

    // MARK: - SpeechRecognizerControllerDelegate

    func didReceivePartialTranscription(_ transcription: String) {
        // no-op
    }

    func didGetFinalResult(_ speechRecognitionResult: SFSpeechRecognitionResult) {
        // no-op
    }

    func transcriptionDidCancel() {
        // no-op
    }

    func didReceiveRequiredPhrase() {

        guard AppConfig.isVoiceExperimentEnabled else {
            return
        }

        let objectID = CategoriesCarouselViewController.fetchVoiceCategoryID()
        guard let desiredIndexPath = dataSourceProxy.indexPath(for: objectID) else {
            return
        }

        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        dataSourceProxy.performActions(on: desiredIndexPath) { (aPath) in
            collectionView.selectItem(at: aPath, animated: false, scrollPosition: [])
        }

        collectionView.scrollToNearestSelectedIndexPathOrCurrentPageBoundary()
        self.categoryObjectID = objectID
    }

}
