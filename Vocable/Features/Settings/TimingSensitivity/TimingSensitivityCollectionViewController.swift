//
//  TimingSensitivityCollectionViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class TimingSensitivityCollectionViewController: UICollectionViewController {
    
    private enum SelectionModeItem: Hashable {
        case dwellTime
        case sensitivity
    }
    
    private let maxDwellTimeDuration = 5.0
    private let minDwellTimeDuration = 0.5
    
    private lazy var dataSource = UICollectionViewDiffableDataSource<Int, SelectionModeItem>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        handleDwellTimeButtonRange()
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
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .dwellTime, .sensitivity:
            return false
        }
    }
     
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
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
            if traitCollection.horizontalSizeClass == .compact
                && traitCollection.verticalSizeClass == .regular {
                cell.topSeparator.isHidden = true
            } else {
                cell.topSeparator.isHidden = false
            }
            return cell
        }
    }
    
    @objc private func handleDecreasingDwellTime(_ sender: UIButton) {
        if AppConfig.selectionHoldDuration > minDwellTimeDuration {
            AppConfig.selectionHoldDuration -= 0.5
        }
        
        handleDwellTimeButtonRange()
    }
    
    @objc private func handleIncreasingDwellTime(_ sender: UIButton) {
        if AppConfig.selectionHoldDuration < maxDwellTimeDuration {
            AppConfig.selectionHoldDuration += 0.5
        }
        
        handleDwellTimeButtonRange()
    }
    
    private func handleDwellTimeButtonRange() {
        guard let indexPath = dataSource.indexPath(for: .dwellTime) else { return }
        guard let dwellTimeCell = collectionView.cellForItem(at: indexPath) as? DwellTimeCollectionViewCell else { return }
        let currentDuration = AppConfig.selectionHoldDuration
        dwellTimeCell.decreaseTimeButton.isEnabled =  currentDuration > minDwellTimeDuration
        dwellTimeCell.increaseTimeButton.isEnabled = currentDuration < maxDwellTimeDuration
        if !dwellTimeCell.decreaseTimeButton.isEnabled || !dwellTimeCell.increaseTimeButton.isEnabled {
            (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
        }
    }
}
