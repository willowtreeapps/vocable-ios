//
//  CategoriesCarouselViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

@IBDesignable class CategoriesCarouselViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {

    @PublishedValue var categoryObjectID: NSManagedObjectID = Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                                                                                matching: NSComparisonPredicate(\Category.isHidden, .equalTo, false),
                                                                                sortDescriptors: [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)])
        .first!.objectID
    @IBOutlet private weak var backChevron: GazeableButton!
    @IBOutlet private weak var forwardChevron: GazeableButton!
    @IBOutlet private weak var collectionViewContainer: UIView!
    @IBOutlet private weak var collectionView: CarouselGridCollectionView!
    @IBOutlet private weak var outerStackView: UIStackView!

    private var collectionViewMask = BorderedView(frame: .zero)

    private lazy var fetchRequest: NSFetchRequest<Category> = {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSComparisonPredicate(\Category.isHidden, .equalTo, false)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.ordinal, ascending: true)]
        return request
    }()

    private lazy var frc = NSFetchedResultsController<Category>(fetchRequest: self.fetchRequest,
                                                                managedObjectContext: NSPersistentContainer.shared.viewContext,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)

    private lazy var dataSourceProxy = CarouselCollectionViewDataSourceProxy<Int, Category>(collectionView: collectionView!) { [weak self] (collectionView, indexPath, category) -> UICollectionViewCell? in
           guard let self = self else { return nil }
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryItemCollectionViewCell
           cell.setup(title: category.name!)
           return cell
       }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .collectionViewBackgroundColor

        collectionViewMask.fillColor = .black
        collectionViewMask.backgroundColor = .clear
        collectionViewContainer.mask = collectionViewMask

        collectionView.register(CategoryItemCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)

        collectionView.delaysContentTouches = true
        collectionView.delegate = self

        updateForCurrentTraitCollection()

        frc.delegate = self
        try? frc.performFetch()

        updateDataSource(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedIndexPaths()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSelectedIndexPaths()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewMask.frame = CGRect(origin: .zero, size: collectionViewContainer.bounds.size)
    }

    private func updateSelectedIndexPaths() {
        let category = frc.managedObjectContext.object(with: categoryObjectID)
        let selectedIndexPath = dataSourceProxy.indexPath(for: category as! Category)
        if let selectedIndexPath = selectedIndexPath {
            dataSourceProxy.performActions(on: selectedIndexPath) { (indexPath) in
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateDataSource(animated: true)
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
            outerStackView.spacing = 0
        } else {
            collectionViewMask.cornerRadius = 16
            collectionView.layout.pageInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
            collectionView.backgroundColor = .categoryBackgroundColor
            outerStackView.spacing = 8
        }

        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.interItemSpacing = 0
            collectionView.layout.numberOfColumns = 4
            collectionView.layout.numberOfRows = .fixedCount(1)
        case .hCompact_vRegular:
            collectionView.layout.interItemSpacing = 8
            collectionView.layout.numberOfColumns = 1
            collectionView.layout.numberOfRows = .fixedCount(1)
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.interItemSpacing = 8
            collectionView.layout.numberOfColumns = 3
            collectionView.layout.numberOfRows = .fixedCount(1)
        default:
            break
        }

    }

    private func updateDataSource(animated: Bool, completion: (() -> Void)? = nil) {
        let content = frc.fetchedObjects ?? []
        var snapshot = NSDiffableDataSourceSnapshot<Int, Category>()
        snapshot.appendSections([0])
        snapshot.appendItems(content)
        dataSourceProxy.apply(snapshot,
                                 animatingDifferences: animated,
                                 completion: completion)
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
            self.collectionViewMask.frame = CGRect(origin: .zero, size: self.collectionViewContainer.bounds.size)
        }, completion: { _ in
            self.updateSelectedItemForHorizontallyCompactLayout()
            self.updateSelectedIndexPaths()
        })
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

        dataSourceProxy.performActions(on: mappedIndexPath) { (aPath) in
            collectionView.selectItem(at: aPath, animated: true, scrollPosition: [])
        }

        let selectedIndexPaths = Set(collectionView.indexPathsForSelectedItems?.map {
            dataSourceProxy.indexPath(fromMappedIndexPath: $0)
            } ?? [])
        for path in selectedIndexPaths where path != mappedIndexPath {
            dataSourceProxy.performActions(on: path) { (aPath) in
                collectionView.deselectItem(at: aPath, animated: true)
            }
        }

        categoryObjectID = frc.object(at: mappedIndexPath).objectID
    }
}
