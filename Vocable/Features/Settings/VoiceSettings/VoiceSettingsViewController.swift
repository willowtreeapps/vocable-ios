//
//  VoiceSettingsViewController.swift
//  Vocable
//
//  Created by Steve Foster on 4/11/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation
import Combine

final class VoiceSettingsViewController: VocableCollectionViewController {

    private enum Section: Hashable {
        case voicePreview
        case personalVoice
    }
    
    private enum Item: Hashable {
        case selectedProfile(VoiceProfileItem)
        case voicePicker
        case personalVoice
    }
    
    private enum SupplementaryKind: String {
        case voicePickerFooter
    }
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

    private var dataSource: DataSource!
    private var cellRegistration: UICollectionView.CellRegistration<VocableListCell, Item>!

    private let previewController = VoiceProfilePreviewController(context: .selectedProfilePreview)
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        updateDataSource()
        
        previewController.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.updateDataSource(items: items)
            }
            .store(in: &cancellables)
    }

    private func setupNavigationBar() {
        navigationBar.title = String(localized: "voice_settings.title")
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    private func updateDataSource(items: [VoiceProfileItem]? = nil) {
        let items = items ?? previewController.items
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.voicePreview])
        snapshot.appendItems(items.map { .selectedProfile($0) })
        snapshot.appendItems([.voicePicker])
        if #available(iOS 17.0, *) {
            // Always show the row on iOS 17+ so users can open the screen and see the compatibility message when unsupported (same pattern as Listening Mode)
            snapshot.appendSections([.personalVoice])
            snapshot.appendItems([.personalVoice])
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func setupCollectionView() {
                
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .collectionViewBackgroundColor
        
        collectionView.register(
            UINib(nibName: "SettingsFooterTextSupplementaryView", bundle: nil),
            forSupplementaryViewOfKind: SupplementaryKind.voicePickerFooter.rawValue,
            withReuseIdentifier: SupplementaryKind.voicePickerFooter.rawValue
        )
        
        let cellRegistration = UICollectionView.CellRegistration<VocableListCell, Item> { [weak self] cell, _, item in
            guard let self else { return }
            switch item {
            case let .selectedProfile(profile):
                cell.contentConfiguration = VocableListContentConfiguration.voiceSelectionPreview(
                    profile,
                    controller: self.previewController
                )
            case .voicePicker:
                cell.contentConfiguration = VocableListContentConfiguration(
                    title: String(localized: "voice_settings.cell.change_voice.title"),
                    trailingAccessory: .disclosureIndicator()
                ) { [weak self] in
                    self?.show(VoicePickerViewController(), sender: nil)
                }
            case .personalVoice:
                if #available(iOS 17.0, *) {
                    cell.contentConfiguration = VocableListContentConfiguration(
                        title: String(localized: "voice_settings.cell.personal_voice.title"),
                        trailingAccessory: .disclosureIndicator()
                    ) { [weak self] in
                        self?.show(PersonalVoiceViewController(), sender: nil)
                    }
                }
            }
        }
        
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
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
            case .voicePickerFooter:
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: elementKind,
                    withReuseIdentifier: elementKind,
                    for: indexPath
                ) as! SettingsFooterTextSupplementaryView
                let format = String(localized: "voice_settings.voice_picker_footer.title")
                let model = UIDevice.current.localizedModel
                footer.textLabel.text = String(format: format, model)
                return footer
            }
        }
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            let section = dataSource.snapshot().sectionIdentifiers[sectionIndex]
            return self?.layoutSection(section: section, environment: environment)
        }
        
        self.dataSource = dataSource
        self.cellRegistration = cellRegistration
    }

    private func layoutSection(section sectionItem: Section, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemHeightDimension: NSCollectionLayoutDimension
        if sizeClass.contains(.vCompact) {
            itemHeightDimension = NSCollectionLayoutDimension.absolute(50)
        } else {
            itemHeightDimension = NSCollectionLayoutDimension.absolute(88)
        }

        let itemWidthDimension = NSCollectionLayoutDimension.fractionalWidth(1.0)
        let columnCount = 1

        let itemSize = NSCollectionLayoutSize(
            widthDimension: itemWidthDimension,
            heightDimension: itemHeightDimension
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: itemWidthDimension,
            heightDimension: itemHeightDimension
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: columnCount
        )
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = sectionInsets(for: environment)
        section.contentInsets.top = 16
        section.contentInsets.bottom = 32
        
        if case .voicePreview = sectionItem {
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: sizeClass.contains(any: .compact) ? .estimated(50) : .estimated(100)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: SupplementaryKind.voicePickerFooter.rawValue,
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
        let item = dataSource.itemIdentifier(for: indexPath)
        if [.voicePicker, .personalVoice].contains(item) {
            return true
        }
        return false
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        if [.voicePicker, .personalVoice].contains(item) {
            return true
        }
        return false
    }
}
