//
//  KeyboardLayoutViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 5/30/23.
//  Copyright © 2023 WillowTree. All rights reserved.
//

import UIKit

final class KeyboardLayoutViewController: VocableCollectionViewController {

    private enum Section: Int {
        case compactQWERTY
    }

    private enum ContentItem: Int {
        case compactQWERTY

        var title: String {
            switch self {
            case .compactQWERTY:
                return String(localized: "settings.cell.qwerty_layout.title")
            }
        }

        var accessibilityID: String {
            switch self {
            case .compactQWERTY:
                return "compact_qwerty_toggle"
            }
        }

        var accessory: VocableListCellAccessory {
            switch self {
            case .compactQWERTY:
                return .toggle(isOn: AppConfig.isCompactPortraitQWERTYKeyboardEnabled)
            }
        }
    }

    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ContentItem>
    private typealias Datasource = UICollectionViewDiffableDataSource<Section, ContentItem>

    private var dataSource: Datasource!

    private var cellRegistration: UICollectionView.CellRegistration<VocableListCell, ContentItem>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource()
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "settings.keyboard_layout.header.title")
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
        updateBackgroundViewLayoutMargins()
    }

    private func updateBackgroundViewLayoutMargins() {
        guard let backgroundView = collectionView.backgroundView else { return }
        backgroundView.directionalLayoutMargins.leading = view.directionalLayoutMargins.leading
        backgroundView.directionalLayoutMargins.trailing = view.directionalLayoutMargins.trailing
    }

    // MARK: UICollectionViewDataSource

    private func updateDataSource(animated: Bool = false) {
        var snapshot = Snapshot()
        snapshot.appendSections([.compactQWERTY])
        snapshot.appendItems([.compactQWERTY])
        collectionView.backgroundView = nil

        if #available(iOS 15.0, *) {
            let reconfigurableItems = [.compactQWERTY].filter(snapshot.itemIdentifiers.contains)
            snapshot.reconfigureItems(reconfigurableItems)
        }

        dataSource.apply(snapshot, animatingDifferences: animated) { [weak self] in
            // Workaround for diffable datasource not auto-reconfiguring on iOS 14
            if #unavailable(iOS 15) {
                self?.updateVisibleCellConfigurations()
            }
        }
    }

    private func setupCollectionView() {

        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "SettingsFooterTextSupplementaryView", bundle: nil),
                                forSupplementaryViewOfKind: "footerText",
                                withReuseIdentifier: "footerText")

        let cellRegistration = UICollectionView.CellRegistration<VocableListCell, ContentItem>(handler: { [weak self] cell, indexPath, item in
            self?.updateContentConfiguration(for: cell, at: indexPath, item: item)
        })

        let dataSource = Datasource(collectionView: collectionView) { (collectionView, indexPath, item) in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) in
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: elementKind, for: indexPath) as! SettingsFooterTextSupplementaryView
            guard let self = self else { return footerView }

            let text: String
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .compactQWERTY:
                let iPhoneName = "iPhone"
                let localizedString = String(localized: "settings.keyboard_layout.qwerty_layout.explanation_footer")
                text = String(format: localizedString, iPhoneName)
            }

            let fontSize: CGFloat = self.sizeClass.contains(any: .compact) ? 18 : 26
            footerView.textLabel.font = .systemFont(ofSize: fontSize)
            footerView.textLabel.text = text
            return footerView
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        let interSectionSpacing: CGFloat = self.sizeClass.contains(any: .compact) ? 16 : 44
        configuration.interSectionSpacing = interSectionSpacing
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (_, environment) -> NSCollectionLayoutSection? in
            return self?.layoutSection(environment: environment)
        }, configuration: configuration)
        collectionView.collectionViewLayout = layout

        self.cellRegistration = cellRegistration
        self.dataSource = dataSource
    }

    private func updateContentConfiguration(for cell: VocableListCell, at indexPath: IndexPath, item: ContentItem) {
        let config = VocableListContentConfiguration(title: item.title,
                                                     accessory: item.accessory,
                                                     accessibilityIdentifier: item.accessibilityID) { [weak self] in
            guard let self = self, let indexPath = self.dataSource.indexPath(for: item) else { return }
            self.collectionView(self.collectionView, didSelectItemAt: indexPath)
        }
        cell.contentConfiguration = config
    }

    private func layoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        if sizeClass.contains(any: .compact) {
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

        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1))
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: "footerText", alignment: .bottom)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 16
        section.contentInsets.bottom = sizeClass.contains(any: .compact) ? 16 : 32
        section.boundarySupplementaryItems = [footerItem]
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
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .compactQWERTY:
            AppConfig.isCompactPortraitQWERTYKeyboardEnabled.toggle()
            Analytics.shared.track(.compactQWERTYKeyboardChanged)
        }

        updateDataSource(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    @available(iOS, obsoleted: 15, message: "Use snapshot-based reconfiguring instead")
    private func updateVisibleCellConfigurations() {
        for indexPath in self.collectionView.indexPathsForVisibleItems {
            if let cell = self.collectionView.cellForItem(at: indexPath) as? VocableListCell {
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
                    continue
                }
                self.updateContentConfiguration(for: cell, at: indexPath, item: item)
            }
        }
    }
}
