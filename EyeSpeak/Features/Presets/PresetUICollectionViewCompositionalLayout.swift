//
//  PresetUICollectionViewFlowLayout.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetUICollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    
    // Dimensions of the product designs.
    // Intended for use in computing the fractional-size dimensions of collection layout items rather than hard-coding width/height values
    private static let totalSize = CGSize(width: 1130, height: 834)
    
    var dataSource: UICollectionViewDiffableDataSource<PresetsViewController.Section, PresetsViewController.ItemWrapper>? {
        self.collectionView?.dataSource as? UICollectionViewDiffableDataSource<PresetsViewController.Section, PresetsViewController.ItemWrapper>
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        // Make animation only happen for preset items
        guard let item = dataSource?.itemIdentifier(for: itemIndexPath) else {
            return attr
        }
        
        switch item {
        case .paginatedPresets, .key, .keyboardFunctionButton:
            attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        default:
            break
        }
        
        return attr
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        // Make animation only happen for preset items
        guard let item = dataSource?.itemIdentifier(for: itemIndexPath) else {
            return attr
        }
        
        switch item {
        case .paginatedPresets, .key, .keyboardFunctionButton:
            attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        default:
            break
        }
        
        return attr
    }
    
    // MARK: - Section Layouts
    
    static func textFieldSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var regularWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            textFieldItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.1), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let subitems = [textFieldItem, functionItem, functionItem, functionItem]
            
            return NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(100.0 / totalSize.height)),
                subitems: subitems)
        }
        
        var compactWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
            textFieldItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let functionItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(0.5)),
                subitems: [functionItem, functionItem])
            
            return NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 4.0)),
                subitems: [textFieldItem, functionItemGroup])
        }
        
        let containerGroup = environment.traitCollection.horizontalSizeClass == .regular ? regularWidthContainerGroupLayout : compactWidthContainerGroupLayout
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    static func categoriesSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let totalSectionWidth: CGFloat = 1130.0
        
        let categoryItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1)))
        let categoriesGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(906.0 / totalSectionWidth),
                                               heightDimension: .fractionalHeight(1)),
            subitems: [categoryItem])
        
        let paginationItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(104.0 / totalSectionWidth),
                                               heightDimension: .fractionalHeight(1)))
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(116.0 / totalSize.height)),
            subitems: [paginationItem, categoriesGroup, paginationItem])
        containerGroup.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        return section
    }
    
    static func predictiveTextSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemCount = CGFloat(4)
        
        let predictiveTextItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / itemCount),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(116.0 / totalSize.height)),
            subitem: predictiveTextItem, count: Int(itemCount))
        containerGroup.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        let backgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: "CategorySectionBackground")
        backgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 8, trailing: 0)
        
        section.decorationItems = [backgroundDecoration]
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        return section
    }
        
    static func presetsSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let flexibleSpacing = (environment.container.contentSize.width / 10.0) * 2.0
        
        let presetPageItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(504.0 / totalSize.height)))
        
        let leadingPaginationItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(146.0 / totalSize.width), heightDimension: .fractionalHeight(1)))
        leadingPaginationItem.edgeSpacing = .init(leading: .flexible(flexibleSpacing), top: nil, trailing: nil, bottom: nil)
        
        let pageIndicatorItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(228.0 / totalSize.width), heightDimension: .fractionalHeight(1)))
        
        let trailingPaginationItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(146.0 / totalSize.width), heightDimension: .fractionalHeight(1)))
        trailingPaginationItem.edgeSpacing = .init(leading: nil, top: nil, trailing: .flexible(flexibleSpacing), bottom: nil)

        let paginationGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(99.0 / totalSize.height)),
            subitems: [leadingPaginationItem, pageIndicatorItem, trailingPaginationItem])
        paginationGroup.interItemSpacing = .fixed(0)
        
        let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(800.0 / totalSize.height)),
            subitems: [presetPageItem, paginationGroup])
        containerGroup.interItemSpacing = .fixed(0)
        
        return NSCollectionLayoutSection(group: containerGroup)
    }
    
    // MARK: Keyboard Layout
    
    static func keyboardSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let keyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        
        // Character key group (Top 3 rows)
        let characterKeyGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
                                                                   subitem: keyItem, count: 10)
        
        let characterKeyContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.75)),
                                                                          subitem: characterKeyGroup, count: 3)
        
        // Function key group (Bottom row)
        
        // Needs to take up space of 2
        let flexibleSpacing = (environment.container.contentSize.width / 10.0) * 2.0
        
        let leadingKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        leadingKeyItem.edgeSpacing = .init(leading: .flexible(flexibleSpacing), top: nil, trailing: nil, bottom: nil)
        
        let spaceKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(3.0 / 10.0), heightDimension: .fractionalHeight(1)))
        
        let trailingKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        trailingKeyItem.edgeSpacing = .init(leading: nil, top: nil, trailing: .flexible(flexibleSpacing), bottom: nil)
        
        let functionKeyGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)),
                                                                  subitems: [leadingKeyItem, spaceKeyItem, keyItem, trailingKeyItem])
        
        let overallContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.7)),
                                                                     subitems: [characterKeyContainerGroup, functionKeyGroup])
        
        let section = NSCollectionLayoutSection(group: overallContainerGroup)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    private static func keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        return item
    }
}
