//
//  TimingSensitivityViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class TimingSensitivityViewController: VocableCollectionViewController {

    private enum SelectionModeItem: Int {
        case dwellTime
        case sensitivity
    }

    private let maxDwellTimeDuration = 5.0
    private let minDwellTimeDuration = 0.5

    private lazy var dataSource = UICollectionViewDiffableDataSource<Int, SelectionModeItem>(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        return self?.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        handleDwellTimeButtonRange()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupNavigationBar() {
        navigationBar.title = String(localized: "timing_and_sensitivity.header.title")
    }

    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "DwellTimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: DwellTimeCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SensitivityCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SensitivityCollectionViewCell.reuseIdentifier)

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] (_, environment) -> NSCollectionLayoutSection? in
            self?.section(environment: environment)
        }

        updateDataSource()
    }

    // MARK: UICollectionViewDataSource

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SelectionModeItem>()
        snapshot.appendSections([0])
        snapshot.appendItems([.dwellTime, .sensitivity])
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func section(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension = NSCollectionLayoutDimension.absolute(130)
        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let columnCount: Int

        if sizeClass == .hCompact_vRegular {
            columnCount = 1
        } else {
            columnCount = 2
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
        group.interItemSpacing = .fixed(16)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 16
        return section
    }

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: 0,
                                       leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
                                       bottom: 0,
                                       trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0))
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .dwellTime, .sensitivity:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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
            cell.decreaseTimeButton.accessibilityID = .settings.timingAndSensitivity.decreaseHoverTimeButton
            cell.increaseTimeButton.accessibilityID = .settings.timingAndSensitivity.increaseHoverTimeButton
            return cell
        case .sensitivity:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SensitivityCollectionViewCell.reuseIdentifier, for: indexPath) as! SensitivityCollectionViewCell
            if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
                cell.topSeparator.isHidden = true
            } else {
                cell.topSeparator.isHidden = false
            }
            return cell
        }
    }

    // MARK: Actions

    @objc private func handleDecreasingDwellTime(_ sender: UIButton) {
        if AppConfig.selectionHoldDuration > minDwellTimeDuration {
            AppConfig.selectionHoldDuration -= 0.5
        }

        handleDwellTimeButtonRange()
        Analytics.shared.track(.hoverTimeChanged)
    }

    @objc private func handleIncreasingDwellTime(_ sender: UIButton) {
        if AppConfig.selectionHoldDuration < maxDwellTimeDuration {
            AppConfig.selectionHoldDuration += 0.5
        }

        handleDwellTimeButtonRange()
        Analytics.shared.track(.hoverTimeChanged)
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
