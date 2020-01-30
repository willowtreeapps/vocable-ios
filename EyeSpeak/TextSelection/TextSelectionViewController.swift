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
        .want: [.presetItem("I want the door closed."),
                .presetItem("I want the door open."),
                .presetItem("I would like to go to the bathroom."),
                .presetItem("I want the lights off."),
                .presetItem("I want the lights on."),
                .presetItem("I want my pillow fixed."),
                .presetItem("I would like some water."),
                .presetItem("I would like some coffee."),
                .presetItem("I want another pillow.")],
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
        collectionView.backgroundColor = .black
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
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(488.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let speakButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(168.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let undoButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(168.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let keyboardButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(176.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [textFieldItem, speakButtonItem, undoButtonItem, keyboardButtonItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.143)),
            subitems: subitems)
        containerGroup.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
//        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(24), top: .fixed(36), trailing: .flexible(24), bottom: .fixed(16))
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func categoriesSectionLayout() -> NSCollectionLayoutSection {
        let category1Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let category2Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let category3Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let category4Item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(170.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let moreCategories = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(304.0 / 1112.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        
        let subitems = [category1Item, category2Item, category3Item, category4Item, moreCategories]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(0.143)),
            subitems: subitems)
        containerGroup.interItemSpacing = .fixed(8)
        
//        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(24), top: .fixed(20), trailing: .flexible(24), bottom: .fixed(16))
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func presetsSectionLayout() -> NSCollectionLayoutSection {
        let presetItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(339.0 / 1112.0),
                                                                                   heightDimension: .fractionalHeight(1.0)))
        
        let rowGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1.0)),
            subitem: presetItem, count: 3)
//        rowGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        rowGroup.interItemSpacing = .fixed(16)
        
        let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(512.0 / 834.0)),
            subitem: rowGroup, count: 3)
//        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(0), top: .fixed(36), trailing: .flexible(0), bottom: .fixed(0))
        containerGroup.interItemSpacing = .fixed(16)
        containerGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.orthogonalScrollingBehavior = .groupPaging
        
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
                cell.setup(title: title, titleColor: .white, textStyle: .footnote, backgroundColor: .black, animationViewColor: .backspaceBloom, borderColor: .white)
                return cell
            case .presetItem(let preset):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackingButtonCollectionViewCell", for: indexPath) as! TrackingButtonCollectionViewCell
                cell.setup(title: preset, titleColor: UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.0), textStyle: .headline, backgroundColor: .white, animationViewColor: .black, borderColor: .clear)
                return cell
            }
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ItemWrapper>()

        snapshot.appendSections([.textField])
        snapshot.appendItems([.textField, .send("speak"), .undo("undo"), .toggleKeyboard("keyboard")])
        snapshot.appendSections([.categories])
        snapshot.appendItems([.category1("Basic Needs"), .category2("Personal Care"), .category3("Salutations"), .category4("Yes | No"), .moreCategories("More Categories")])
        
        snapshot.appendSections([.presets])
        snapshot.appendItems(categoryPresets[.want]!)
            
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}
