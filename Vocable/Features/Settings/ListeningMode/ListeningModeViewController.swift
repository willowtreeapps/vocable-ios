//
//  ListeningModeViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 1/19/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import UIKit
import CoreData
import Combine

final class ListeningModeViewController: VocableCollectionViewController {

    private enum Section: Int {
        case listeningMode
        case smartAssist
        case hotword
    }

    private enum ContentItem: Int {
        case listeningModeEnabled
        case smartAssistEnabled
        case hotWordEnabled

        var title: String {
            switch self {
            case .listeningModeEnabled:
                return String(localized: "settings.listening_mode.listening_mode_toggle_cell.title")
            case .hotWordEnabled:
                return String(localized: "settings.listening_mode.hot_word_toggle_cell.title")
            case .smartAssistEnabled:
                return String(localized: "settings.listening_mode.smart_assist_toggle_cell.title")
            }
        }

        var accessibilityID: String {
            switch self {
            case .listeningModeEnabled:
                return "listening_mode_toggle"
            case .hotWordEnabled:
                return "hot_word_toggle"
            case .smartAssistEnabled:
                return "use_gpt_toggle"
            }
        }

        var accessory: VocableListCellAccessory {
            switch self {
            case .listeningModeEnabled:
                return .toggle(isOn: AppConfig.listeningMode.listeningModeEnabledPreference
                              && ListenModeFeatureConfiguration.deviceSupportsListeningMode)
            case .hotWordEnabled:
                return .toggle(isOn: AppConfig.listeningMode.hotwordEnabledPreference)
            case .smartAssistEnabled:
                return .toggle(isOn: AppConfig.listeningMode.smartAssistEnabledPreference)
            }
        }
    }

    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ContentItem>
    private typealias Datasource = UICollectionViewDiffableDataSource<Section, ContentItem>

    private var dataSource: Datasource!

    private var authorizationController = AudioPermissionPromptController(mode: .hotWord)
    private var authorizationCancellable: AnyCancellable?
    private var cellRegistration: UICollectionView.CellRegistration<VocableListCell, ContentItem>!

    override func viewDidLoad() {
        super.viewDidLoad()

        authorizationCancellable = authorizationController.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDataSource(animated: true)
            }
        setupNavigationBar()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource()
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "settings.listening_mode.title")
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
        if let state = authorizationController.state {
            if !ListenModeFeatureConfiguration.deviceSupportsListeningMode {
                collectionView.backgroundView  = EmptyStateView(type: ListeningEmptyState.listeningModeUnsupported)
            } else {
                collectionView.backgroundView = EmptyStateView.listening(state.state, action: state.action)
            }

            updateBackgroundViewLayoutMargins()
        } else {
            snapshot.appendSections([.listeningMode])
            snapshot.appendItems([.listeningModeEnabled])
            if AppConfig.listeningMode.listeningModeEnabledPreference, ListenModeFeatureConfiguration.deviceSupportsListeningMode {
                snapshot.appendSections([.hotword])
                snapshot.appendItems([.hotWordEnabled])
                
                snapshot.appendSections([.smartAssist])
                snapshot.appendItems([.smartAssistEnabled])
            }
            collectionView.backgroundView = nil
        }

        if #available(iOS 15.0, *) {
            let reconfigurableItems = [.smartAssistEnabled, .hotWordEnabled, .listeningModeEnabled].filter(snapshot.itemIdentifiers.contains)
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
            if ListenModeFeatureConfiguration.deviceSupportsListeningMode {
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                switch section {
                case .listeningMode:
                    text = String(localized: "settings.listening_mode.listening_mode_explanation_footer")
                case .hotword:
                    text = String(localized: "settings.listening_mode.hotword_explanation_footer")
                case .smartAssist:
                    text = String(localized: "settings.listening_mode.smart_assist_explanation_footer")
                }
            } else {
                let model = UIDevice.current.localizedModel
                let systemName = UIDevice.current.systemName
                let systemVersion = UIDevice.current.systemVersion
                let siriName = "Siri"

                let format = String(localized: "settings.listening_mode.device_unsupported_explanation_footer")

                text = String(format: format, model, systemName, systemVersion, siriName)
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
                                                     isPrimaryActionEnabled: ListenModeFeatureConfiguration.deviceSupportsListeningMode,
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
        case .listeningModeEnabled:
            AppConfig.listeningMode.listeningModeEnabledPreference.toggle()
            Analytics.shared.track(.listeningModeChanged)

            let context = NSPersistentContainer.shared.newBackgroundContext()
            context.perform {
                try? Category.updateAllOrdinalValues(in: context)
                try? context.save()
            }

        case .hotWordEnabled:
            AppConfig.listeningMode.hotwordEnabledPreference.toggle()
            Analytics.shared.track(.heyVocableModeChanged)
            
        case .smartAssistEnabled:
            AppConfig.listeningMode.smartAssistEnabledPreference.toggle()
            Analytics.shared.track(.smartAssistModeChanged)
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
