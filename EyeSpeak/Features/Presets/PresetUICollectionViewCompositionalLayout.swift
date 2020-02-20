//
//  PresetUICollectionViewFlowLayout.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PresetUICollectionViewCompositionalLayout: UICollectionViewCompositionalLayout {
    
    // Height dimension of the product designs.
    // Intended for use in computing the fractional-size dimensions of collection layout items rather than hard-coding width/height values
    private static let totalHeight: CGFloat = 834.0
    
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
        case .key, .keyboardFunctionButton:
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
        case .key, .keyboardFunctionButton:
            attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        default:
            break
        }
        
        return attr
    }
    
    // MARK: - Section Layouts
    
    static func topBarSectionLayout() -> NSCollectionLayoutSection {
        let redoButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(116.0 / 240.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let keyboardButtonItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(116.0 / 240.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [redoButtonItem, keyboardButtonItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(64.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 256, bottom: 0, trailing: 256)
        
        return section
    }
    
    static func textFieldSectionLayout() -> NSCollectionLayoutSection {
        let textFieldItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let subitems = [textFieldItem]
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(86.0 / totalHeight)),
            subitems: subitems)
        containerGroup.interItemSpacing = .flexible(0)
        containerGroup.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(400), top: .fixed(0), trailing: .flexible(400), bottom: .fixed(0))
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    static func categoriesSectionLayout() -> NSCollectionLayoutSection {
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
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(137.0 / totalHeight)),
            subitems: [paginationItem, categoriesGroup, paginationItem])
        containerGroup.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        return section
    }
    
    static func predictiveTextSectionLayout() -> NSCollectionLayoutSection {
        let itemCount = CGFloat(4)
        
        let predictiveTextItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / itemCount),
                                               heightDimension: .fractionalHeight(1.0)))
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(137.0 / totalHeight)),
            subitem: predictiveTextItem, count: Int(itemCount))
        containerGroup.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        return section
    }
        
    static func presetsSectionLayout() -> NSCollectionLayoutSection {
        let presetPageItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1)))
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(552.0 / totalHeight)),
            subitems: [presetPageItem])
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        footer.extendsBoundary = true
        footer.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [footer]
        
        return section
    }
    
    // MARK: Keyboard Layout
    
    static func keyboardSectionLayout() -> NSCollectionLayoutSection {
        let keyboardKeyItem = keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        
        let keyboardRowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitem: keyboardKeyItem, count: 10)
        
        let keyboardContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 2.0)), subitem: keyboardRowGroup, count: 3)
        
        let section = NSCollectionLayoutSection(group: keyboardContainerGroup)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    private static func keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        let item = NSCollectionLayoutItem(layoutSize: layoutSize)
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        return item
    }
}
