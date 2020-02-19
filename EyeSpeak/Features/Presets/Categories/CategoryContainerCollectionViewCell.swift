//
//  CategoryContainerCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryContainerCollectionViewCell: VocableCollectionViewCell, UICollectionViewDelegate {
    
    private enum Section {
        case categories
    }

    private enum ItemWrapper: Hashable {
        case category(PresetCategory)
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
        configureDataSource()
        
        collectionView.selectItem(at: dataSource.indexPath(for: .category(.category1)), animated: false, scrollPosition: .init())
    }
    
//    override func updateContentViews() {
//        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
//        borderedView.fillColor = .defaultCellBackgroundColor
//        borderedView.isOpaque = true
//    }
    
    private func setupCollectionView() {
        self.collectionView.dataSource = dataSource
        self.collectionView.delegate = self
        
        self.collectionView.backgroundColor = .defaultCellBackgroundColor
        self.collectionView.delaysContentTouches = false

        let layout = createLayout()
        collectionView.collectionViewLayout = layout
//        collectionView.reloadData()
        
        collectionView.register(UINib(nibName: CategoryItemCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)
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
        // Move this to the pagination buttons
        paginate()
    }
    
    func paginate() {
        guard let largestIndexPath = collectionView.indexPathsForVisibleItems.max() else {
            return
        }
        
        let nextRow = largestIndexPath.row + 1
        if collectionView.numberOfItems(inSection: largestIndexPath.section) > nextRow {
            collectionView.scrollToItem(at: IndexPath(row: nextRow, section: largestIndexPath.section), at: .left, animated: true)
        } else {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: largestIndexPath.section), at: .left, animated: true)
        }
    }
    
}
