//
//  SelectionModeViewController.swift
//  Vocable AAC
//
//  Created by Thomas Shealy on 3/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class SelectionModeViewController: VocableCollectionViewController {

    private enum SelectionModeItem: Int {
        case headTrackingToggle
    }

    private enum SupplementaryKind: String {
        case headTrackingUnsupportedFooter
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, SelectionModeItem> = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
        return self?.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
    }

    private func setupNavigationBar() {
        navigationBar.title = NSLocalizedString("selection_mode.header.title", comment: "Selection mode screen header title")
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
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
        collectionView.register(UINib(nibName: "SettingsFooterTextSupplementaryView", bundle: nil),
                                forSupplementaryViewOfKind: SupplementaryKind.headTrackingUnsupportedFooter.rawValue,
                                withReuseIdentifier: SupplementaryKind.headTrackingUnsupportedFooter.rawValue)

        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) in
            switch SupplementaryKind(rawValue: elementKind) {
            case .none:
                return nil
            case .headTrackingUnsupportedFooter:

                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: elementKind, for: indexPath) as! SettingsFooterTextSupplementaryView
                footer.textLabel.text = SelectionModeViewController.headTrackingUnsupportedLocalizedString
                return footer
            }
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (_, environment) -> NSCollectionLayoutSection? in
            return self?.layoutSection(environment: environment)
        })
    }

    private func layoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        if sizeClass.contains(.vCompact) {
            itemHeightDimension = NSCollectionLayoutDimension.absolute(50)
        } else {
            itemHeightDimension = NSCollectionLayoutDimension.absolute(100)
        }

        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let columnCount = 1

        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemWidthDimension, heightDimension: itemHeightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 16
        section.contentInsets.bottom = 32
        if !AppConfig.isHeadTrackingSupported {

            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                     elementKind: SupplementaryKind.headTrackingUnsupportedFooter.rawValue,
                                                                     alignment: .bottom)
            section.boundarySupplementaryItems = [footer]
        }
        return section
    }

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        return NSDirectionalEdgeInsets(top: 0,
                                       leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
                                       bottom: 0,
                                       trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .headTrackingToggle:
            return AppConfig.isHeadTrackingSupported
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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
            cell.setup(title: title, value: AppConfig.$isHeadTrackingEnabled)
            return cell
        }
    }

    // MARK: Helpers

    private func toggleHeadTracking() {
        AppConfig.isHeadTrackingEnabled.toggle()
    }

    private static var headTrackingUnsupportedLocalizedString: String {

        // Attempting to follow these guidelines: https://developer.apple.com/app-store/marketing/guidelines/
        // These trademarks should not be localized unless the system provides the localized string
        let model = UIDevice.current.localizedModel
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let sensorName = "TrueDepth"
        let neuralEngineName = "Apple Neural Engine"

        let format = NSLocalizedString("settings.selection_mode.head_tracking_unsupported_footer",
                                       comment: "Footer text explaining that the user's device and/or operating system version is incompatible with head tracking and which devices do support head tracking")

        let text = String(format: format, model, systemName, systemVersion, sensorName, neuralEngineName)
        return text
    }

}
