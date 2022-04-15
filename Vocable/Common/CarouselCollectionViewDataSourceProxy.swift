//
//  CarouselCollectionViewDataSourceProxy.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 4/16/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CarouselCollectionViewDataSourceProxy<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: NSObject {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    private typealias Impl = UICollectionViewDiffableDataSource<ContentWrapper<SectionIdentifier>, ContentWrapper<ItemIdentifier>>

    private struct ContentWrapper<Element: Hashable>: Hashable {
        let index: Int
        let item: Element
    }

    private let updateQueue = DispatchQueue(label: "carousel-update-queue")
    private let repeatCount = 100
    private let collectionView: UICollectionView
    private let cellProvider: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    private var impl: Impl!
    private var lastSnapshot: Snapshot?

    init(collectionView: UICollectionView, cellProvider: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?) {
        self.cellProvider = cellProvider
        self.collectionView = collectionView
        super.init()

        self.impl = Impl(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) in
            guard let self = self else { return nil }
            let mappedPath = self.indexPath(fromMappedIndexPath: indexPath)
            return self.cellProvider(collectionView, mappedPath, item.item)
        })

        if let collectionView = collectionView as? CarouselGridCollectionView {
            collectionView.dataSourceProxyInvalidationCallback = { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let selections = collectionView.indexPathsForSelectedItems
                    let snapshot = self.snapshot()
                    self.apply(snapshot, animatingDifferences: false) {
                        let afterSnapshot = self.snapshot()
                        if snapshot.numberOfItems == afterSnapshot.numberOfItems {
                            for path in selections ?? [] {
                                collectionView.selectItem(at: path, animated: false, scrollPosition: [])
                            }
                        }
                    }
                }
            }
        }
    }

    func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> {
        if let lastSnapshot = lastSnapshot {
            return lastSnapshot
        }
        let _snapshot = impl.snapshot()
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        if let firstSection = _snapshot.sectionIdentifiers.first {
            snapshot.appendSections([firstSection.item])
            snapshot.appendItems(_snapshot.itemIdentifiers(inSection: firstSection).map(\.item))
        }
        return snapshot
    }

    func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {

        let carouselLayout = self.collectionView.collectionViewLayout as? CarouselGridLayout

        let repeatCount: Int
        if let carouselLayout = carouselLayout, snapshot.itemIdentifiers.count > carouselLayout.itemsPerPage {
            repeatCount = self.repeatCount
        } else {
            repeatCount = 1
        }

        lastSnapshot = snapshot

        updateQueue.async { [weak self] in
            guard let self = self else { return }
            var repeatedSnapshot = NSDiffableDataSourceSnapshot<ContentWrapper<SectionIdentifier>, ContentWrapper<ItemIdentifier>>()

            if let firstSection = snapshot.sectionIdentifiers.first {

                for index in 0 ..< repeatCount {
                    let section = ContentWrapper(index: index, item: firstSection)
                    repeatedSnapshot.appendSections([section])
                    for originalItem in snapshot.itemIdentifiers {

                        let item = ContentWrapper(index: index, item: originalItem)
                        repeatedSnapshot.appendItems([item])

                        if #available(iOS 15.0, *), snapshot.reconfiguredItemIdentifiers.contains(originalItem) {
                            repeatedSnapshot.reconfigureItems([item])
                        }
                        if #available(iOS 15.0, *), snapshot.reloadedItemIdentifiers.contains(originalItem) {
                            repeatedSnapshot.reloadItems([item])
                        }
                    }

                    if #available(iOS 15.0, *), snapshot.reloadedSectionIdentifiers.contains(firstSection) {
                        repeatedSnapshot.reloadSections([section])
                    }
                }
            }

            self.impl.apply(repeatedSnapshot, animatingDifferences: animatingDifferences, completion: completion)
        }
    }

    private func mappedIndexPaths(`for` indexPath: IndexPath) -> [IndexPath] {
        guard let identifier = impl.itemIdentifier(for: indexPath) else { return [] }
        let snapshot = impl.snapshot()
        let indexPaths = snapshot.sectionIdentifiers.compactMap { section -> IndexPath? in
            return impl.indexPath(for: .init(index: section.index, item: identifier.item))
        }
        return indexPaths
    }

    func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifier? {
        return impl.itemIdentifier(for: indexPath)?.item
    }

    func indexPath(for itemIdentifier: ItemIdentifier) -> IndexPath? {
        return impl.indexPath(for: .init(index: 0, item: itemIdentifier))
    }

    func indexPath(fromMappedIndexPath indexPath: IndexPath) -> IndexPath {
        return IndexPath(item: indexPath.item, section: 0)
    }

    func performActions(on indexPath: IndexPath, actions: (IndexPath) -> Void) {
        for indexPath in mappedIndexPaths(for: indexPath) {
            actions(indexPath)
        }
    }

}
