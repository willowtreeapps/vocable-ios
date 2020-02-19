//
//  CategoryPageCollectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CategoryPageCollectionViewController: UICollectionViewController {
    
    static let didSelectCategoryNotificationName = Notification.Name("didSelectCategory")
    
    static func createLayout(with itemCount: Int) -> UICollectionViewLayout {
        let letterItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let letterGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitem: letterItem, count: itemCount)
        let section = NSCollectionLayoutSection(group: letterGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    var items: [PresetCategory] = [] {
        didSet {
            setupCollectionView()
            configureDataSource()
        }
    }
    
    private enum Section {
        case categories
    }
    
    private enum ItemWrapper: Hashable {
        case category(PresetCategory)
    }
        
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let item = dataSource.itemIdentifier(for: indexPath),
                case let .category(category) = item,
                (self.parent as? CategoriesPageViewController)?.selectedCategory == category else {
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
        snapshot.appendItems(items.map { .category($0) })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
      
    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
        
        if case let .category(category) = itemIdentifier {
            NotificationCenter.default.post(name: CategoryPageCollectionViewController.didSelectCategoryNotificationName, object: category)
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
