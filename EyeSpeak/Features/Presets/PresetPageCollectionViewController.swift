//
//  PresetPageCollectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/20/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import AVFoundation

class PresetPageCollectionViewController: UICollectionViewController {
    
    var items: [PhraseViewModel] = [] {
        didSet {
            setupCollectionView()
            configureDataSource()
        }
    }
    
    private enum Section {
        case presets
    }
    
    private enum ItemWrapper: Hashable {
        case presetItem(PhraseViewModel)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let item = dataSource.itemIdentifier(for: indexPath),
                case let .presetItem(preset) = item,
            ItemSelection.selectedPhrase == preset else {
                    collectionView.deselectItem(at: indexPath, animated: false)
                    continue
            }
            
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
            return
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .collectionViewBackgroundColor
        
        collectionView.register(UINib(nibName: CategoryItemCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: CategoryItemCollectionViewCell.reuseIdentifier)
        collectionView.register(UINib(nibName: PresetItemCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (_: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .presetItem(let viewModel):
                let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier, for: indexPath) as! PresetItemCollectionViewCell
                cell.setup(title: viewModel.utterance)
                
                return cell
            }
        })
        
        updateSnapshot()
    }
    
    // MARK: - NSDiffableDataSourceSnapshot construction
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()
        snapshot.appendSections([.presets])
        snapshot.appendItems(items.map { .presetItem($0) })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch selectedItem {
        case .presetItem(let viewModel):
            ItemSelection.selectedPhrase = viewModel

            // Dispatch to get off the main queue for performance
            DispatchQueue.global(qos: .userInitiated).async {
                AVSpeechSynthesizer.shared.speak(viewModel.utterance)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case .presetItem:
            return false
        }
    }
    
    class CompositionalLayout: UICollectionViewCompositionalLayout {
        private var dataSource: UICollectionViewDiffableDataSource<PresetPageCollectionViewController.Section, PresetPageCollectionViewController.ItemWrapper>? {
            self.collectionView?.dataSource as? UICollectionViewDiffableDataSource<PresetPageCollectionViewController.Section, PresetPageCollectionViewController.ItemWrapper>
        }
        
        // Height dimension of the product designs.
        // Intended for use in computing the fractional-size dimensions of collection layout items rather than hard-coding width/height values
        private static let totalHeight: CGFloat = 834.0
        
        init(traitCollection: UITraitCollection) {
            super.init(section: CompositionalLayout.presetsSectionLayout(for: traitCollection))
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private static func presetsSectionLayout(for traitCollection: UITraitCollection) -> NSCollectionLayoutSection {
            let presetItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3.0),
                                                                                       heightDimension: .fractionalHeight(1.0)))
            
            var itemsPerRow: Int {
                switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
                case (.regular, .regular), (.regular, .compact):
                    return 3
                default:
                    return 2
                }
            }
            
            let rowGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitem: presetItem, count: itemsPerRow)
            rowGroup.interItemSpacing = .fixed(8)
            
            let containerGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1)),
                subitem: rowGroup, count: 3)
            containerGroup.interItemSpacing = .fixed(8)
            containerGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return section
        }
    }
}
