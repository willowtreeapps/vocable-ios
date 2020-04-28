//
//  SelectionModeCollectionViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class SelectionModeCollectionViewController: UICollectionViewController {
    
    private enum SelectionModeItem: String, Hashable {

        case headTrackingToggle = "Head Tracking"

        var title: String {
            return self.rawValue
        }
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
        snapshot.appendItems([.headTrackingToggle])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "SettingsToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier)
        
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
        let headTrackingToggleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headTrackingToggleGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/9))
        let headTrackingToggleGroup = NSCollectionLayoutGroup.vertical(layoutSize: headTrackingToggleGroupSize, subitems: [headTrackingToggleItem])
        
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
            let title = NSLocalizedString("gaze_settings.alert.disable_head_tracking_confirmation.title",
                                          comment: "Disable head tracking confirmation alert title")
            let cancelButtonTitle = NSLocalizedString("gaze_settings.alert.disable_head_tracking_confirmation.button.cancel.title",
                                                      comment: "Cancel alert action title")
            let confirmButtonTitle = NSLocalizedString("gaze_settings.alert.disable_head_tracking_confirmation.button.confirm.title",
                                                       comment: "Confirm alert action title")
            let alertViewController = GazeableAlertViewController.init(alertTitle: title)
            alertViewController.addAction(GazeableAlertAction(title: cancelButtonTitle))
            alertViewController.addAction(GazeableAlertAction(title: confirmButtonTitle, style: .bold, handler: self.toggleHeadTracking))
            present(alertViewController, animated: true)
        } else {
            AppConfig.isHeadTrackingEnabled.toggle()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .headTrackingToggle:
            return AppConfig.isHeadTrackingSupported
        }
    }
     
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .headTrackingToggle:
            return AppConfig.isHeadTrackingSupported
        }
    }

    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: SelectionModeItem) -> UICollectionViewCell {
        switch item {
        case .headTrackingToggle:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsToggleCollectionViewCell
            let title = NSLocalizedString("settings.cell.head_tracking.title",
                                          comment: "Settings head tracking cell title")
            cell.setup(title: title)
            return cell
        }
    }

    // MARK: Helpers

    private func toggleHeadTracking() {
        AppConfig.isHeadTrackingEnabled.toggle()
    }
}
