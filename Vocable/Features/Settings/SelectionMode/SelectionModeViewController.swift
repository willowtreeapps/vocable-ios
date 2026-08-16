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
        case compactQWERTY
        case useBuiltInKeyboard
    }

    private enum SupplementaryKind: String {
        case headTrackingUnsupportedFooter
        case compactQwertyDescriptionFooter
    }

    private enum SectionIdentifier: Int {
        case headTracking
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifier, SelectionModeItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, SelectionModeItem>
    private typealias CellRegistration = UICollectionView.CellRegistration<VocableListCell, SelectionModeItem>
    
    private var dataSource: DataSource!
    private var cellRegistration: CellRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "selection_mode.header.title")
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource

    private func updateDataSource(animated: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.headTracking])
        snapshot.appendItems([.headTrackingToggle, .useBuiltInKeyboard])
        if AppConfig.isHeadTrackingEnabled {
            snapshot.appendItems([.compactQWERTY])
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func registerSupplementaryFooter(_ item: SupplementaryKind) {
        collectionView.register(
            UINib(nibName: "SettingsFooterTextSupplementaryView", bundle: nil),
            forSupplementaryViewOfKind: item.rawValue,
            withReuseIdentifier: item.rawValue
        )
    }

    private func setupCollectionView() {
        collectionView.delaysContentTouches = false
        
        collectionView.backgroundColor = .collectionViewBackgroundColor
        registerSupplementaryFooter(.headTrackingUnsupportedFooter)
        registerSupplementaryFooter(.compactQwertyDescriptionFooter)

        let cellRegistration = CellRegistration { cell, _, item in
            switch item {
            case .headTrackingToggle:
                cell.contentConfiguration = VocableListContentConfiguration.toggleCell(
                    title: String(localized: "settings.cell.head_tracking.title"),
                    isOn: AppConfig.isHeadTrackingEnabled,
                    isPrimaryActionEnabled: AppConfig.isHeadTrackingSupported,
                    accessibilityIdentifier: .settings.selectionMode.headTrackingToggle
                ) { [weak self] in
                    self?.toggleHeadTracking()
                }
            case .compactQWERTY:
                cell.contentConfiguration = VocableListContentConfiguration.toggleCell(
                    title: String(localized: "settings.cell.qwerty_layout.title"),
                    isOn: AppConfig.isCompactQWERTYKeyboardEnabled,
                    accessibilityIdentifier: .settings.selectionMode.compactQwertyToggle
                ) { [weak self] in
                    self?.toggleCompactQwerty()
                }
            case .useBuiltInKeyboard:
                cell.contentConfiguration = VocableListContentConfiguration.toggleCell(
                    title: String(localized: "settings.cell.use_builtin_keyboard.title"),
                    isOn: AppConfig.isBuiltInKeyboardEnabled,
                    accessibilityIdentifier: .settings.selectionMode.useBuiltInKeyboardToggle
                ) { [weak self] in
                    self?.toggleUseBuiltInKeyboard()
                }
            }
        }
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) in
            switch SupplementaryKind(rawValue: elementKind) {
            case .none:
                return nil
            case .headTrackingUnsupportedFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: elementKind,
                    for: indexPath
                ) as! SettingsFooterTextSupplementaryView
                footer.textLabel.text = SelectionModeViewController.headTrackingUnsupportedLocalizedString
                return footer
            case .compactQwertyDescriptionFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: elementKind,
                    for: indexPath
                ) as! SettingsFooterTextSupplementaryView
                footer.textLabel.text = String(localized: "settings.keyboard_layout.qwerty_layout.explanation_footer")
                return footer
            }
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] _, environment in
            self?.layoutSection(environment: environment)
        }
        self.cellRegistration = cellRegistration
    }

    private func layoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        if sizeClass.contains(.vCompact) {
            itemHeightDimension = NSCollectionLayoutDimension.absolute(50)
        } else {
            itemHeightDimension = NSCollectionLayoutDimension.absolute(88)
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

        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        if !AppConfig.isHeadTrackingSupported {
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: SupplementaryKind.headTrackingUnsupportedFooter.rawValue,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]
        } else if AppConfig.isHeadTrackingEnabled {
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: SupplementaryKind.compactQwertyDescriptionFooter.rawValue,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]
        }
        return section
    }

    private func sectionInsets(for environment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
        NSDirectionalEdgeInsets(
            top: 0,
            leading: max(view.layoutMargins.left - environment.container.contentInsets.leading, 0),
            bottom: 0,
            trailing: max(view.layoutMargins.right - environment.container.contentInsets.trailing, 0)
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathForGazedItem != indexPath {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
            return switch item {
            case .compactQWERTY, .useBuiltInKeyboard: true
            case .headTrackingToggle: AppConfig.isHeadTrackingSupported
            }
        }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        return switch item {
        case .compactQWERTY, .useBuiltInKeyboard: true
        case .headTrackingToggle: AppConfig.isHeadTrackingSupported
        }
    }

    // MARK: Helpers

    private func toggleCompactQwerty() {
        AppConfig.isCompactQWERTYKeyboardEnabled.toggle()
        dataSource.reloadItem(.compactQWERTY, animated: false)
    }

    private func toggleUseBuiltInKeyboard() {
        AppConfig.isBuiltInKeyboardEnabled.toggle()
        dataSource.reloadItem(.useBuiltInKeyboard, animated: false)
    }

    private func toggleHeadTracking() {
        if AppConfig.isHeadTrackingEnabled {
            let title = String(localized: "gaze_settings.alert.disable_head_tracking_confirmation.title")
            let cancelButtonTitle = String(localized: "gaze_settings.alert.disable_head_tracking_confirmation.button.cancel.title")
            let confirmButtonTitle = String(localized: "gaze_settings.alert.disable_head_tracking_confirmation.button.confirm.title")
            let alertViewController = GazeableAlertViewController.init(alertTitle: title)
            alertViewController.addAction(GazeableAlertAction(title: cancelButtonTitle))
            alertViewController.addAction(GazeableAlertAction(title: confirmButtonTitle, style: .bold) { [weak self] in
                AppConfig.isHeadTrackingEnabled.toggle()
                self?.headTrackingDidChange()
            })
            present(alertViewController, animated: true)
        } else {
            AppConfig.isHeadTrackingEnabled.toggle()
            headTrackingDidChange()
            Analytics.shared.track(.headingTrackingChanged)
        }
    }

    private func headTrackingDidChange() {
        dataSource.reloadItem(.headTrackingToggle, animated: false)
        if AppConfig.isHeadTrackingEnabled {
            dataSource.appendItem(.compactQWERTY, in: .headTracking)
        } else {
            dataSource.removeItem(.compactQWERTY)
        }
    }

    private static var headTrackingUnsupportedLocalizedString: String {

        // Attempting to follow these guidelines: https://developer.apple.com/app-store/marketing/guidelines/
        // These trademarks should not be localized unless the system provides the localized string
        let model = UIDevice.current.localizedModel
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        let sensorName = "TrueDepth"
        let neuralEngineName = "Apple Neural Engine"

        let format = String(localized: "settings.selection_mode.head_tracking_unsupported_footer")

        let text = String(format: format, model, systemName, systemVersion, sensorName, neuralEngineName)
        return text
    }

}
