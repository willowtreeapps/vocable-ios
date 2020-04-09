//
//  EditCategoryDetailCollectionViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
<<<<<<< HEAD
import CoreData
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06

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
    
<<<<<<< HEAD
    private let context = NSPersistentContainer.shared.viewContext
    
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
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
<<<<<<< HEAD
        collectionView.allowsMultipleSelection = true
        collectionView.allowsSelection = true
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
        
        updateDataSource()
        
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let showCategoryToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        showCategoryToggleItem.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        var showRemoveCategoryGroupFractionalHeight: NSCollectionLayoutDimension {
            if case .compact = traitCollection.verticalSizeClass {
                return .fractionalHeight(1 / 3)
            }
            return .fractionalHeight(1 / 8)
        }
        
        let showRemoveCategoryGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: showRemoveCategoryGroupFractionalHeight)
        let showRemoveCategoryGroup = NSCollectionLayoutGroup.vertical(layoutSize: showRemoveCategoryGroupSize, subitems: [showCategoryToggleItem])
        
        let section = NSCollectionLayoutSection(group: showRemoveCategoryGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
<<<<<<< HEAD
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }
    for _ in collectionView.indexPathsForSelectedItems ?? [] {
        switch selectedItem {
        case .showCategoryToggle:
            break
        case .removeCategoryToggle:
            guard let category = EditCategoryDetailViewController.category else { return }
            context.delete(category)
            saveContext()
        }
    }
    }
=======
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
        switch item {
        case .showCategoryToggle:
           return false
        case .removeCategoryToggle:
           return false
        }
    }
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06

   private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: EditCategoryItem) -> UICollectionViewCell {
       switch item {
       case .showCategoryToggle:
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryToggleCollectionViewCell
<<<<<<< HEAD
           cell.showCategorySwitch.addTarget(self, action: #selector(self.handleToggle(_:)), for: .valueChanged)
           return cell
       case .removeCategoryToggle:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryRemoveCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryRemoveCollectionViewCell
        cell.isHidden = (!(EditCategoryDetailViewController.category?.isUserGenerated ?? true))
        return cell
    }
   }
    
    @objc func handleToggle(_ sender: UISwitch) {
        let shouldShowCategory = sender.isOn
        guard let category = EditCategoryDetailViewController.category else { return }
        category.setValue(shouldShowCategory, forKey: "isHidden")
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            assertionFailure("Failed to unsave user generated phrase: \(error)")
        }
    }
=======
           return cell
       case .removeCategoryToggle:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditCategoryRemoveCollectionViewCell.reuseIdentifier, for: indexPath) as! EditCategoryRemoveCollectionViewCell
        return cell
    }
   }
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06

}
