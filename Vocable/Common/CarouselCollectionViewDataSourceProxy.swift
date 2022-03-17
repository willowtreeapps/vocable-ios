//
//  CarouselCollectionViewDataSourceProxy.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 4/16/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CarouselCollectionViewDataSourceProxy<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: NSObject {

    private struct ContentWrapper<Element: Hashable>: Hashable {
        let index: Int
        let item: Element
    }

    private let repeatCount = 100
    private let collectionView: UICollectionView
    private let cellProvider: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    private lazy var impl = UICollectionViewDiffableDataSource<ContentWrapper<SectionIdentifier>, ContentWrapper<ItemIdentifier>>(collectionView: collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) in
        guard let self = self else { return nil }
        let mappedPath = self.indexPath(fromMappedIndexPath: indexPath)
        return self.cellProvider(collectionView, mappedPath, item.item)
    })

    init(collectionView: UICollectionView, cellProvider: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?) {
        self.cellProvider = cellProvider
        self.collectionView = collectionView
        super.init()

        if let collectionView = collectionView as? CarouselGridCollectionView {
            collectionView.dataSourceProxyInvalidationCallback = { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let selections = collectionView.indexPathsForSelectedItems
                    let snapshot = self.snapshot()
                    self.apply(snapshot, animatingDifferences: false)
                    let afterSnapshot = self.snapshot()
                    if snapshot.itemIdentifiers.count == afterSnapshot.itemIdentifiers.count {
                        for path in selections ?? [] {
                            collectionView.selectItem(at: path, animated: false, scrollPosition: [])
                        }
                    }
                }
            }
        }
    }

    func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier> {
        let _snapshot = impl.snapshot()
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        if let firstSection = _snapshot.sectionIdentifiers.first {
            snapshot.appendSections([firstSection.item])
            snapshot.appendItems(_snapshot.itemIdentifiers(inSection: firstSection).map {$0.item})
        }
        return snapshot
    }

    func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        var repeatedSnapshot = NSDiffableDataSourceSnapshot<ContentWrapper<SectionIdentifier>, ContentWrapper<ItemIdentifier>>()
        if let firstSection = snapshot.sectionIdentifiers.first {

            let repeatCount: Int
            if let carouselLayout = collectionView.collectionViewLayout as? CarouselGridLayout, snapshot.itemIdentifiers.count > carouselLayout.itemsPerPage {
                repeatCount = self.repeatCount
            } else {
                repeatCount = 1
            }
            for index in 0..<repeatCount {
                repeatedSnapshot.appendSections([.init(index: index, item: firstSection)])
                repeatedSnapshot.appendItems(snapshot.itemIdentifiers.map {.init(index: index, item: $0)})
            }
        }
        if #available(iOS 15, *), !animatingDifferences {
            impl.applySnapshotUsingReloadData(repeatedSnapshot, completion: completion)
        } else {
            impl.apply(repeatedSnapshot, animatingDifferences: animatingDifferences, completion: completion)
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
