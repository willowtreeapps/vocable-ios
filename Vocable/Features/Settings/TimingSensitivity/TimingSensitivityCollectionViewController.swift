//
//  TimingSensitivityCollectionViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TimingSensitivityCollectionViewController: UICollectionViewController {
    
    private enum SelectionModeItem: Hashable {
        case dwellTime
        case sensitivity
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, SelectionModeItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    // MARK: UICollectionViewDataSource
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SelectionModeItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.dwellTime, .sensitivity])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "DwellTimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DwellTimeCollectionViewCell")
        collectionView.register(UINib(nibName: "SensitivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SensitivityCollectionViewCell")
        
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
    
    private func compactVerticalLayout() -> UICollectionViewLayout {
        let headTrackingToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headTrackingToggleGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/5))
        let headTrackingToggleGroup = NSCollectionLayoutGroup.vertical(layoutSize: headTrackingToggleGroupSize, subitems: [headTrackingToggleItem])
        
        let section = NSCollectionLayoutSection(group: headTrackingToggleGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func defaultLayout() -> UICollectionViewLayout {
        let settingsItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
        let headTrackingToggleGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/5))
        let headTrackingToggleGroup = NSCollectionLayoutGroup.horizontal(layoutSize: headTrackingToggleGroupSize, subitems: [settingsItem, settingsItem])
        
        let section = NSCollectionLayoutSection(group: headTrackingToggleGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        if AppConfig.isHeadTrackingEnabled {
            //let alertViewController = GazeableAlertViewController.make { AppConfig.isHeadTrackingEnabled.toggle() }
            let alertViewController = GazeableAlertViewController.init(alertTitle: "Turn off head tracking?")
            present(alertViewController, animated: true)
        } else {
            AppConfig.isHeadTrackingEnabled.toggle()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
         let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
         switch item {
         case .dwellTime, .sensitivity:
            return false
         }
     }
     
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
         let item = dataSource.snapshot().itemIdentifiers[indexPath.item]
         switch item {
         case .dwellTime, .sensitivity:
            return false
         }
     }

    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: SelectionModeItem) -> UICollectionViewCell {
        switch item {
        case .dwellTime:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DwellTimeCollectionViewCell.reuseIdentifier, for: indexPath) as! DwellTimeCollectionViewCell
            return cell
        case .sensitivity:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SensitivityCollectionViewCell.reuseIdentifier, for: indexPath) as! SensitivityCollectionViewCell
            return cell
        }

    }
}
