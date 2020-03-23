//
//  SelectionModeCollectionViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SelectionModeCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    // MARK: UICollectionViewDataSource
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "SettingsToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SettingsToggleCollectionViewCell")
        
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

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
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
            let alertViewController = GazeableAlertViewController.make { AppConfig.isHeadTrackingEnabled.toggle() }
            present(alertViewController, animated: true)
            alertViewController.setAlertTitle("Turn off head tracking?")
        } else {
            AppConfig.isHeadTrackingEnabled.toggle()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsToggleCollectionViewCell
        cell.setup(title: NSLocalizedString("Head Tracking", comment: "Head tracking cell title"))
        return cell
    }
}
