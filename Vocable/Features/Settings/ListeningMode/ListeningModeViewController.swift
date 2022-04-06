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

    private enum ContentItem: Int {
        case listeningModeEnabled
        case hotWordEnabled
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, ContentItem> = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell in
        return self.collectionView(collectionView, cellForItemAt: indexPath, item: item)
    }

    private var authorizationController = AudioPermissionPromptController()
    private var authorizationCancellable: AnyCancellable?

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
        #warning("Needs localization")
        navigationBar.title = "Listening Mode"
    }

    // MARK: UICollectionViewDataSource

    private func updateDataSource(animated: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ContentItem>()
        if let state = authorizationController.state {
            collectionView.backgroundView = EmptyStateView.listening(state.state, action: state.action)
        } else {
            snapshot.appendSections([0])
            snapshot.appendItems([.listeningModeEnabled])
            if AppConfig.isListeningModeEnabled {
                snapshot.appendItems([.hotWordEnabled])
            }
            collectionView.backgroundView = nil
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .collectionViewBackgroundColor
        collectionView.register(UINib(nibName: "SettingsToggleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: "SettingsFooterTextSupplementaryView", bundle: nil),
                                forSupplementaryViewOfKind: "footerText",
                                withReuseIdentifier: "footerText")

        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) in
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: elementKind, for: indexPath) as! SettingsFooterTextSupplementaryView
            footerView.textLabel.text = """
When this shortcut is enabled, someone saying \"Hey Vocable\" aloud will automatically navigate to the listening mode screen.

This shortcut makes it fast to kick off a conversation by saying something like \"Hey Vocable, are you feeling okay?\" and jumping straight to the suggested responses.
"""
            return footerView
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

        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500))
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: "footerText", alignment: .bottom)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 16
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
            AppConfig.isListeningModeEnabled.toggle()
            updateDataSource(animated: true)
            let context = NSPersistentContainer.shared.viewContext
            context.perform {
                let listeningModeCategory = Category.fetch(.listeningMode, in: context)
                listeningModeCategory.isHidden = !AppConfig.isListeningModeEnabled
                try? Category.updateAllOrdinalValues(in: context)
                try? context.save()
            }

        case .hotWordEnabled:
            AppConfig.isHotWordPermitted.toggle()
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .listeningModeEnabled:
            return true
        case .hotWordEnabled:
            return AppConfig.isListeningModeEnabled && AppConfig.isVoiceExperimentEnabled
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        switch item {
        case .listeningModeEnabled:
            return true
        case .hotWordEnabled:
            return AppConfig.isListeningModeEnabled && AppConfig.isVoiceExperimentEnabled
        }
    }

    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: ContentItem) -> UICollectionViewCell {
        switch item {
        case .listeningModeEnabled:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsToggleCollectionViewCell
            #warning("Needs localization")
            let title = "Listening mode"
            cell.setup(title: title, value: AppConfig.$isListeningModeEnabled)
            return cell
        case .hotWordEnabled:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsToggleCollectionViewCell.reuseIdentifier, for: indexPath) as! SettingsToggleCollectionViewCell
            #warning("Needs localization")
            let title = "\"Hey Vocable\" shortcut"
            cell.setup(title: title, value: AppConfig.$isHotWordPermitted)
            return cell
        }
    }
}
