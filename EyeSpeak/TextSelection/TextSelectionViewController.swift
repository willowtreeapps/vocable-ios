//
//  TextSelectionViewController.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TextSelectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Category {
        case want
        case need
        case three
        case confirmation
    }
    
    private var categoryPresets: [Category : [ItemWrapper]] = [
        .want: (1...9).map { .presetItem("Want \($0)") },
        .need: (1...9).map { .presetItem("Need \($0)") },
        .three: (1...9).map { .presetItem("Three \($0)") },
        .confirmation: (1...9).map { .presetItem("Yes \($0)") },
    ]
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, ItemWrapper>!
    
    enum Section: Int, CaseIterable {
        case textField
        case categories
        case presets
    }
    
    enum ItemWrapper: Hashable {
        case textField
        case send(String)
        case undo(String)
        case toggleKeyboard(String)
        case category1(String)
        case category2(String)
        case category3(String)
        case category4(String)
        case moreCategories(String)
        case presetItem(String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "TextFieldCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TextFieldCollectionViewCell")
        collectionView.register(UINib(nibName: "TrackingButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrackingButtonCollectionViewCell")
        collectionView.collectionViewLayout = createLayout()
        configureDataSource()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .textField:
                return self.textFieldSectionLayout()
            case .categories:
                return self.categoriesSectionLayout()
            case .presets:
                return self.presetsSectionLayout()
            }
        }
        return layout
    }
    
    private func textFieldSectionLayout() -> NSCollectionLayoutSection {
        // TODO: implemnet edge insets and spacing like the categories section layout
        let textFieldItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.438),
                                               heightDimension: .fractionalHeight(1.0)))
        let speakButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.179),
                                               heightDimension: .fractionalHeight(1.0)))
        let undoButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.179),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let keyboardButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.179),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [textFieldItem, speakButtonItem, undoButtonItem, keyboardButtonItem]
        subitems.forEach {
            $0.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 8)
        }
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.143)),
            subitems: subitems)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 36, leading: 0, bottom: 16, trailing: 0)
        
        return section
    }
    
    private func categoriesSectionLayout() -> NSCollectionLayoutSection {
        let category1Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.152),
                                               heightDimension: .fractionalHeight(1.0)))
        let category2Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.152),
                                               heightDimension: .fractionalHeight(1.0)))
        let category3Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.152),
                                               heightDimension: .fractionalHeight(1.0)))
        let category4Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.152),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let moreCategories = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.273),
                                               heightDimension: .fractionalHeight(1.0)))
        
        
        let subitems = [category1Item, category2Item, category3Item, category4Item, moreCategories]
        subitems.forEach {
            $0.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(0), top: .flexible(0), trailing: .flexible(0), bottom: .flexible(0))
        }
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.143)),
            subitems: subitems)
        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(24), top: .fixed(16), trailing: .flexible(24), bottom: .fixed(16))
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    private func presetsSectionLayout() -> NSCollectionLayoutSection {
        let presetItems = (0..<3).map { _ in NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.304),
                                               heightDimension: .fractionalHeight(1.0))) }
        
        presetItems.forEach {
            $0.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(0), top: .flexible(0), trailing: .flexible(0), bottom: .flexible(0))
        }
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(144.0 / 834.0)),
            subitems: presetItems)
        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(24), top: .fixed(16), trailing: .flexible(24), bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemWrapper>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: ItemWrapper) -> UICollectionViewCell? in
            
            switch identifier {
            case .textField:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextFieldCollectionViewCell", for: indexPath) as! TextFieldCollectionViewCell
                return cell
            case .send(let title), .undo(let title), .toggleKeyboard(let title), .category1(let title), .category2(let title), .category3(let title), .category4(let title), .moreCategories(let title):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: title, backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            case .presetItem(let preset):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: preset, backgroundColor: .backspaceFill, animationViewColor: .backspaceBloom, hoverBorderColor: .backspaceBorderHover)
                return cell
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()

        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField, .send("speak"), .undo("undo"), .toggleKeyboard("keyboard")])
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category1("I want..."), .category2("I am..."), .category3("Will you..."), .category4("Confirmations"), .moreCategories("More Categories")])
        
        snapshot.appendSections([.presets])
        snapshot.appendItems(categoryPresets[.want]!)
            
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}
