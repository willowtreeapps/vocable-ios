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
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "DwellTimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DwellTimeCollectionViewCell")
        collectionView.register(UINib(nibName: "SensitivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SensitivityCollectionViewCell")
        
        updateDataSource()
        
        let layout = createLayout()
        collectionView.collectionViewLayout = layout
    }
    
    private func createLayout() -> UICollectionViewLayout {
        if case .compact = traitCollection.horizontalSizeClass,
            case .regular = traitCollection.verticalSizeClass {
            return compactWidthLayout()
        } else {
            return defaultLayout()
        }
    }
    
    private func compactWidthLayout() -> UICollectionViewLayout {
        let settingsItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/5))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [settingsItem, settingsItem])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func defaultLayout() -> UICollectionViewLayout {
        let settingsItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
        let fractionalHeight = CGFloat(traitCollection.verticalSizeClass == .compact ? 0.5 : 0.225)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(fractionalHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [settingsItem, settingsItem])
        
        let section = NSCollectionLayoutSection(group: group)
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
            cell.decreaseTimeButton.addTarget(self,
                                        action: #selector(self.handleDecreasingDwellTime(_:)),
                                        for: .primaryActionTriggered)
            cell.increaseTimeButton.addTarget(self,
                                      action: #selector(self.handleIncreasingDwellTime(_:)),
                                      for: .primaryActionTriggered)
            return cell
        case .sensitivity:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SensitivityCollectionViewCell.reuseIdentifier, for: indexPath) as! SensitivityCollectionViewCell
            return cell
        }
    }
    
    @objc private func handleDecreasingDwellTime(_ sender: UIButton) {
        if AppConfig.selectionHoldDuration > 0.5 {
            AppConfig.selectionHoldDuration -= 0.5
        }
    }
    
    @objc private func handleIncreasingDwellTime(_ sender: UIButton) {
        if AppConfig.selectionHoldDuration < 5 {
            AppConfig.selectionHoldDuration += 0.5
        }
    }
}
