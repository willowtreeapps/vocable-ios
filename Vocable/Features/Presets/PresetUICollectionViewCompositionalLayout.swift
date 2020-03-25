//
//  PresetUICollectionViewFlowLayout.swift
//  Vocable AAC
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
        case .paginatedPresets, .key, .keyboardFunctionButton, .paginatedCategories:
            attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        default:
            break
        }
        
        return attr
    }
    
    // MARK: - Section Layouts
    
    static func topBarPresetSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var regularWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            textFieldItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.15), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let subitems = [textFieldItem, functionItem, functionItem]
            
            return NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(116.0 / totalSize.height)),
                subitems: subitems)
        }
        
        var compactWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(2 / 3)))
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 0, bottom: 0, trailing: 4)

            let functionItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1 / 3)),
                subitems: [functionItem, functionItem])
            
            return NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 5.0)),
                subitems: [textFieldItem, functionItemGroup])
        }
        
        let containerGroup = environment.traitCollection.horizontalSizeClass == .compact && environment.traitCollection.verticalSizeClass == .regular ? compactWidthContainerGroupLayout : regularWidthContainerGroupLayout
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    static func topBarKeyboardSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var regularWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            textFieldItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let functionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.1), heightDimension: .fractionalHeight(1.0)))
            functionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            
            let subitems = [textFieldItem, functionItem, functionItem, functionItem]
            
            return NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(116.0 / totalSize.height)),
                subitems: subitems)
        }
        
        var compactWidthContainerGroupLayout: NSCollectionLayoutGroup {
            let textFieldItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(2 / 3)))
            
            let leadingFunctionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1.0)))
            leadingFunctionItem.contentInsets = .init(top: 4, leading: 0, bottom: 0, trailing: 4)
            let innerFunctionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1.0)))
            innerFunctionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 4)
            let trailingFunctionItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 3), heightDimension: .fractionalHeight(1.0)))
            trailingFunctionItem.contentInsets = .init(top: 4, leading: 4, bottom: 0, trailing: 0)

            let functionItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1 / 3)),
                subitems: [leadingFunctionItem, innerFunctionItem, trailingFunctionItem])
            
            return NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 5.0)),
                subitems: [textFieldItem, functionItemGroup])
        }
        
        let containerGroup = environment.traitCollection.horizontalSizeClass == .compact &&
            environment.traitCollection.verticalSizeClass == .regular ? compactWidthContainerGroupLayout : regularWidthContainerGroupLayout
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        return section
    }
    
    static func categoriesSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let totalSectionWidth: CGFloat = 1130.0
        let traitCollection = environment.traitCollection
        
        let categoryItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1)))
        if case .compact = environment.traitCollection.horizontalSizeClass {
            categoryItem.contentInsets = .init(top: 0, leading: 8, bottom: 0, trailing: 8)
        }
        
        var categoryGroupFractionalWidth: NSCollectionLayoutDimension {
            if case .regular = traitCollection.horizontalSizeClass {
                return .fractionalWidth(906.0 / totalSectionWidth)
            }
            
            if traitCollection.verticalSizeClass == .compact
                && traitCollection.horizontalSizeClass == .compact {
                return .fractionalWidth(4 / 5.0)
            }
            
            return .fractionalWidth(3.0 / 5.0)
        }
        
        let categoriesGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: categoryGroupFractionalWidth,
                                               heightDimension: .fractionalHeight(1)),
            subitems: [categoryItem])
        
        var paginationItemFractionalWidth: NSCollectionLayoutDimension {
            if case .regular = traitCollection.horizontalSizeClass {
                return .fractionalWidth(104.0 / totalSectionWidth)
            }
            
            if traitCollection.verticalSizeClass == .compact
                && traitCollection.horizontalSizeClass == .compact {
                return .fractionalWidth(0.5 / 5.0)
            }
            
            return .fractionalWidth(1.0 / 5.0)
        }
        
        let paginationItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: paginationItemFractionalWidth,
                                               heightDimension: .fractionalHeight(1)))
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(116.0 / totalSize.height)),
            subitems: [paginationItem, categoriesGroup, paginationItem])
        containerGroup.interItemSpacing = .flexible(0)
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    static func suggestiveTextSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        var regularWidthSection: NSCollectionLayoutSection {
            let itemCount = CGFloat(4)
            
            let suggestiveTextItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / itemCount),
                                                   heightDimension: .fractionalHeight(1.0)))
            
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(116.0 / totalSize.height)),
                subitem: suggestiveTextItem, count: Int(itemCount))
            containerGroup.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            let section = NSCollectionLayoutSection(group: containerGroup)
            
            let backgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: "CategorySectionBackground")
            backgroundDecoration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
            
            section.decorationItems = [backgroundDecoration]
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
            return section
        }
        
        var compactWidthSection: NSCollectionLayoutSection {
            let suggestiveTextItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / 2),
                                                   heightDimension: .fractionalHeight(1.0)))
            
            let suggestiveTextRow = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1)),
                subitem: suggestiveTextItem, count: Int(2))
            suggestiveTextRow.interItemSpacing = .fixed(8)
            
            let containerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1 / 6)),
            subitem: suggestiveTextRow, count: Int(2))
            containerGroup.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
            return section
        }
        
        return environment.traitCollection.horizontalSizeClass == .compact &&
            environment.traitCollection.verticalSizeClass == .regular ? compactWidthSection : regularWidthSection

    }
        
    static func presetsSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        var regularWidthPresetGroup: NSCollectionLayoutGroup {
            let flexibleSpacing = (environment.container.contentSize.width / 10.0) * 2.0
            
            let presetPageItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(490.0 / totalSize.height)))
            
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
            
            var containerGroupFractionalWidth: NSCollectionLayoutDimension {
                if case .compact = environment.traitCollection.verticalSizeClass {
                    return .fractionalHeight(750.0 / totalSize.height)
                }
                
                return .fractionalHeight(800.0 / totalSize.height)
            }
            
            let containerGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: containerGroupFractionalWidth),
                subitems: [presetPageItem, paginationGroup])
            return containerGroup
        }
        
        let compactHeightPresetGroup = regularWidthPresetGroup
        
        var compactWidthPresetGroup: NSCollectionLayoutGroup {
            let presetPageItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(504.0 / totalSize.height)))
            
            let paginationItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 4.0), heightDimension: .fractionalHeight(1)))
            
            let pageIndicatorItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2.0 / 4.0), heightDimension: .fractionalHeight(1)))
            
            let paginationGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(99.0 / totalSize.height)),
                subitems: [paginationItem, pageIndicatorItem, paginationItem])
            paginationGroup.interItemSpacing = .fixed(0)
            
            let containerGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(3.75 / 5.0)),
                subitems: [presetPageItem, paginationGroup])
            
            return containerGroup
        }
        
        let containerGroup: NSCollectionLayoutGroup
        if case .compact = environment.traitCollection.verticalSizeClass {
            containerGroup = compactHeightPresetGroup
        } else {
            containerGroup = environment.traitCollection.horizontalSizeClass == .regular ? regularWidthPresetGroup : compactWidthPresetGroup
        }
        
        containerGroup.interItemSpacing = .fixed(8)
    
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        return section
    }
    
    // MARK: Keyboard Layout
    
    static func landscapeKeyboardSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let keyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        
        // Character key group (Top 3 rows)
        let characterKeyGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitem: keyItem, count: 10)
        
        let characterKeyContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.75)), subitem: characterKeyGroup, count: 3)
        
        // Function key group (Bottom row)
        let flexibleSpacing = (environment.container.contentSize.width / 10.0) * 2.0
        
        let leadingKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        leadingKeyItem.edgeSpacing = .init(leading: .flexible(flexibleSpacing), top: nil, trailing: nil, bottom: nil)
        
        let spaceKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(3.0 / 10.0), heightDimension: .fractionalHeight(1)))
        
        let trailingKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 10.0), heightDimension: .fractionalHeight(1)))
        trailingKeyItem.edgeSpacing = .init(leading: nil, top: nil, trailing: .flexible(flexibleSpacing), bottom: nil)
        
        let functionKeyGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.25)),
                                                                  subitems: [leadingKeyItem, spaceKeyItem, keyItem, trailingKeyItem])
        
        let overallFractionHeight = environment.traitCollection.verticalSizeClass == .compact ? CGFloat(0.625) : CGFloat(0.675)
        
        let overallContainerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(overallFractionHeight)),
            subitems: [characterKeyContainerGroup, functionKeyGroup])
        
        let section = NSCollectionLayoutSection(group: overallContainerGroup)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    static func portraitKeyboardSectionLayout(with environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let keyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 6.0), heightDimension: .fractionalHeight(1)))
        
        // Character key group (Top 3 rows)
        let characterKeyGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitem: keyItem, count: 6)
        
        let characterKeyContainerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(5 / 6)), subitem: characterKeyGroup, count: 5)
        
        // Function key group (Bottom row)
        
        let leadingKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 6.0), heightDimension: .fractionalHeight(1)))
        
        let spaceKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(3.0 / 6.0), heightDimension: .fractionalHeight(1)))
        
        let trailingKeyItem = PresetUICollectionViewCompositionalLayout.keyboardCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 6.0), heightDimension: .fractionalHeight(1)))
        
        let functionKeyGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1 / 6)),
            subitems: [leadingKeyItem, spaceKeyItem, keyItem, trailingKeyItem])
        
        let overallContainerGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.55)),
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
