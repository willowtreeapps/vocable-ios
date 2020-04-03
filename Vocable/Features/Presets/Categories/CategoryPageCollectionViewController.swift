//
//  CategoryPageCollectionViewController.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryPageCollectionViewController: UICollectionViewController {
    
    static func createLayout(with itemCount: Int) -> UICollectionViewLayout {
        let letterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let letterGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: letterItem, count: itemCount)
        let section = NSCollectionLayoutSection(group: letterGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    var items: [CategoryViewModel] = [] {
        didSet {
            setupCollectionView()
            configureDataSource()
        }
    }
    
    private enum Section {
        case categories
    }
    
    private enum ItemWrapper: Hashable {
        case category(CategoryViewModel)
    }
        
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let item = dataSource.itemIdentifier(for: indexPath),
                case let .category(category) = item,
            ItemSelection.selectedCategory == category else {
                    collectionView.deselectItem(at: indexPath, animated: false)
                continue
            }
            
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            return
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .categoryBackgroundColor
        
        collectionView.register(CategoryItemCollectionViewCell.self, forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (_: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .category(let category):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryItemCollectionViewCell
                cell.setup(title: category.name)
                
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    // MARK: - NSDiffableDataSourceSnapshot construction
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        snapshot.appendSections([.categories])
        snapshot.appendItems(items.map { .category($0) })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
      
    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if case let .category(category) = dataSource.itemIdentifier(for: indexPath) {
            ItemSelection.selectedCategory = category
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .category:
            return false
        }
    }
}
