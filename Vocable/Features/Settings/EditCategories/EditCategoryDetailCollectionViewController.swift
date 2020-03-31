//
//  EditCategoryDetailCollectionViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class EditCategoryDetailCollectionViewController: UICollectionViewController {
    
    private enum EditCategoryItem: String, Hashable {
        var title: String {
            return self.rawValue
        }
        
        case showCategoryToggle = "Show"
        case removeCategoryToggle = "Remove Category"
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, EditCategoryItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    // MARK: UICollectionViewDataSource
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, EditCategoryItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.showCategoryToggle, .removeCategoryToggle])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "EditCategoryToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EditCategoryToggleCollectionViewCell")
        collectionView.register(UINib(nibName: "EditCategoryRemoveCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EditCategoryRemoveCollectionViewCell")
        
        updateDataSource()
        
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        if case .compact = self.traitCollection.verticalSizeClass {
            return compactVerticalLayout()
        } else {
            return defaultLayout()
        }
    }
    
    private func defaultLayout() -> UICollectionViewLayout {
        let showCategoryToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        showCategoryToggleItem.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        let showRemoveCategoryGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/9))
        let showRemoveCategoryGroup = NSCollectionLayoutGroup.vertical(layoutSize: showRemoveCategoryGroupSize, subitems: [showCategoryToggleItem])
        
        let section = NSCollectionLayoutSection(group: showRemoveCategoryGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func compactVerticalLayout() -> UICollectionViewLayout {
        let showCategoryToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        showCategoryToggleItem.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        let showRemoveCategoryGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/5))
        let showRemoveCategoryGroup = NSCollectionLayoutGroup.vertical(layoutSize: showRemoveCategoryGroupSize, subitems: [showCategoryToggleItem])
        
        let section = NSCollectionLayoutSection(group: showRemoveCategoryGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .showCategoryToggle:
           return false
        case .removeCategoryToggle:
           return false
        }
    }

   private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: EditCategoryItem) -> UICollectionViewCell {
       switch item {
       case .showCategoryToggle:
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryToggleCollectionViewCell
           return cell
       case .removeCategoryToggle:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryRemoveCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryRemoveCollectionViewCell
        return cell
    }
   }

}
