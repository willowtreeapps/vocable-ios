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
    private typealias DataSource = UICollectionViewDiffableDataSource<ContentWrapper<SectionIdentifier>, ContentWrapper<ItemIdentifier>>

    private struct ContentWrapper<Element: Hashable>: Hashable {
        let index: Int
        let item: Element
    }

    private let updateQueue = DispatchQueue(label: "carousel-update-queue")
    private let repeatCount = 100
    private let collectionView: UICollectionView
    private let cellProvider: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    private var dataSource: DataSource!

    init(collectionView: UICollectionView, cellProvider: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?) {
        self.cellProvider = cellProvider
        self.collectionView = collectionView
        super.init()

        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) in
            guard let self = self else { return nil }
            let mappedPath = self.indexPath(fromMappedIndexPath: indexPath)
            return self.cellProvider(collectionView, mappedPath, item.item)
        })
    }

    func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> {
        let _snapshot = dataSource.snapshot()
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

            self.dataSource.apply(repeatedSnapshot, animatingDifferences: animatingDifferences, completion: completion)
        }
    }

    private func mappedIndexPaths(`for` indexPath: IndexPath) -> [IndexPath] {
        guard let identifier = dataSource.itemIdentifier(for: indexPath) else { return [] }
        let snapshot = dataSource.snapshot()
        let indexPaths = snapshot.sectionIdentifiers.compactMap { section -> IndexPath? in
            return dataSource.indexPath(for: .init(index: section.index, item: identifier.item))
        }
        return indexPaths
    }

    func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifier? {
        return dataSource.itemIdentifier(for: indexPath)?.item
    }

    func indexPath(for itemIdentifier: ItemIdentifier) -> IndexPath? {
        return dataSource.indexPath(for: .init(index: 0, item: itemIdentifier))
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
