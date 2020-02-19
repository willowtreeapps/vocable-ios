//
//  CategoryContainerCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_: PresetCategory)
}

class CategoryContainerCollectionViewCell: VocableCollectionViewCell, UICollectionViewDelegate {
    
    private enum Section {
        case categories
    }

    private enum ItemWrapper: Hashable {
        case category(PresetCategory)
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    weak var categorySelectionDelegate: CategorySelectionDelegate?
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    private lazy var pageViewController = CategoriesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupPageViewController()
        borderedView.fillColor = .categoryBackgroundColor
    }
    
    private func setupPageViewController() {
        
        pageViewController.view.frame = contentView.frame
        let pageView = pageViewController.view!
        
        contentView.addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        
        collectionView.register(UINib(nibName: CategoryItemCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (_: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .category(let category):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryItemCollectionViewCell
                cell.setup(title: category.description)

                return cell
            }
        })
        
        updateSnapshot()
    }
    
    // MARK: - NSDiffableDataSourceSnapshot construction
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        snapshot.appendSections([.categories])
        snapshot.appendItems(PresetCategory.allCases.map { .category($0) })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
        
    private func createLayout() -> UICollectionViewLayout {
        let letterItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let letterItem = NSCollectionLayoutItem(layoutSize: letterItemSize)
        
        let letterGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let letterGroup = NSCollectionLayoutGroup.horizontal(layoutSize: letterGroupSize, subitem: letterItem, count: 4)
        
        let section = NSCollectionLayoutSection(group: letterGroup)
        section.orthogonalScrollingBehavior = .paging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
        
        if case let .category(category) = itemIdentifier {
            categorySelectionDelegate?.didSelectCategory((category))
        }
    }
    
    func paginate(_ direction: PaginationDirection) {
//        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        switch direction {
        case .forward:
            break
//            guard let largestIndexPath = visibleIndexPaths.max() else {
//                return
//            }
//
//            let nextRow = largestIndexPath.row + 1
//            var targetScrollRow = 0
//            if collectionView.numberOfItems(inSection: largestIndexPath.section) > nextRow {
//                targetScrollRow = nextRow
//            }
//
//            collectionView.scrollToItem(at: IndexPath(row: targetScrollRow, section: largestIndexPath.section), at: .left, animated: true)
        case .backward:
            break
//            collectionView.select
//            guard let smallestIndexPath = visibleIndexPaths.min() else {
//                return
//            }
//
//            let previousRow = smallestIndexPath.row - visibleIndexPaths.count
//
//            var targetScrollRow: Int
//            if previousRow > 0 {
//                targetScrollRow = max(0, smallestIndexPath.row - )
//            } else {
//                targetScrollRow = max(collectionView.numberOfItems(inSection: smallestIndexPath.section) - visibleIndexPaths.count - 1, 0)
//            }
//
//            print(targetScrollRow)
//            collectionView.scrollToItem(at: IndexPath(row: targetScrollRow, section: smallestIndexPath.section), at: .left, animated: true)
        }
    }
}
