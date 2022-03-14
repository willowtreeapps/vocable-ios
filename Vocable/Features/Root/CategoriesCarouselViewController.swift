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
import Combine

@IBDesignable class CategoriesCarouselViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {

    static func fetchInitialCategoryID() -> NSManagedObjectID {
        let ctx = NSPersistentContainer.shared.viewContext
        let predicate = !Predicate(\Category.isHidden)
        let sort = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        let categories = Category.fetchAll(in: ctx, matching: predicate, sortDescriptors: sort)
        return categories[0].objectID
    }

    static func fetchVoiceCategoryID() -> NSManagedObjectID {
        let ctx = NSPersistentContainer.shared.viewContext
        let predicate = Predicate(\Category.identifier, equalTo: Category.Identifier.listeningMode)
        let categories = Category.fetchAll(in: ctx, matching: predicate)
        return categories[0].objectID
    }

    @PublishedValue private(set) var categoryObjectID = fetchInitialCategoryID()
    private var hotWordCancellable: AnyCancellable?
    private var listeningModeEnabledCancellable: AnyCancellable?

    @IBOutlet private weak var backChevron: GazeableButton!
    @IBOutlet private weak var forwardChevron: GazeableButton!
    @IBOutlet private weak var collectionViewContainer: UIView!
    @IBOutlet private weak var collectionView: CarouselGridCollectionView!
    @IBOutlet private weak var outerStackView: UIStackView!

    private var collectionViewMask = BorderedView(frame: .zero)

    private var frc: NSFetchedResultsController<Category>!

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

        updateFetchedResultsController()

        hotWordCancellable = SpeechRecognitionController.shared.$transcription
            .filter { value in
                if case .hotWord = value {
                    return true
                }
                return false
            }.receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigateToVoiceCategory()
            }

        listeningModeEnabledCancellable = AppConfig.$isListeningModeEnabled
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.listeningModeEnabledStateDidChange(isEnabled)
            }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionViewMaskFrame()
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

    private func categoriesFetchRequest() -> NSFetchRequest<Category> {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        var predicate = !Predicate(\Category.isHidden)

        let shouldRemoveListeningCategory = false
        || !AppConfig.isListeningModeSupported
        || !AppConfig.isVoiceExperimentEnabled
        || !AppConfig.isListeningModeEnabled
        || !SpeechRecognitionController.shared.deviceSupportsSpeech

        if shouldRemoveListeningCategory {
            predicate &= Predicate(\Category.identifier, notEqualTo: Category.Identifier.listeningMode)
        }
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        return request
    }

    private func categoriesFetchedResultsController() -> NSFetchedResultsController<Category> {
        return NSFetchedResultsController<Category>(fetchRequest: categoriesFetchRequest(),
                                                    managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
    }

    private func updateFetchedResultsController() {
        frc?.delegate = nil

        let controller = categoriesFetchedResultsController()
        controller.delegate = self
        frc = controller
        try? frc.performFetch()
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

    private func listeningModeEnabledStateDidChange(_ isEnabled: Bool) {

        let previousSelectedCategory = categoryObjectID
        updateFetchedResultsController()

        let destinationIndexPath: IndexPath
        let destinationObjectID: NSManagedObjectID
        if let desiredIndexPath = dataSourceProxy.indexPath(for: previousSelectedCategory) {
            destinationIndexPath = desiredIndexPath
            destinationObjectID = previousSelectedCategory
        } else {
            let initialCategory = CategoriesCarouselViewController.fetchInitialCategoryID()
            guard let indexPath = dataSourceProxy.indexPath(for: initialCategory) else { return }
            destinationIndexPath = indexPath
            destinationObjectID = initialCategory
        }

        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        dataSourceProxy.performActions(on: destinationIndexPath) { (aPath) in
            collectionView.selectItem(at: aPath, animated: false, scrollPosition: [])
        }

        collectionView.scrollToNearestSelectedIndexPathOrCurrentPageBoundary()
        self.categoryObjectID = destinationObjectID
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

    private func navigateToVoiceCategory() {

        guard AppConfig.isVoiceExperimentEnabled else {
            return
        }

        if self.presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }

        let objectID = CategoriesCarouselViewController.fetchVoiceCategoryID()
        guard categoryObjectID != objectID, let desiredIndexPath = dataSourceProxy.indexPath(for: objectID) else {
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
