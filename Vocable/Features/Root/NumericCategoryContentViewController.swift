//
//  NumericCategoryContentViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 5/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class NumericCategoryContentViewController: PagingCarouselViewController {

    private static let formatter = NumberFormatter()

    private lazy var diffableDataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: self.collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
        let cell = collectionView.dequeueCell(type: PresetItemCollectionViewCell.self, for: indexPath)
        cell.setup(title: item)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge.all.subtracting(.top)
        view.layoutMargins.top = 4
        
        isPaginationViewHidden = true
        updateLayoutForCurrentTraitCollection()

        collectionView.register(PresetItemCollectionViewCell.self, forCellWithReuseIdentifier: PresetItemCollectionViewCell.reuseIdentifier)

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(contentItems())

        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayoutForCurrentTraitCollection()
    }

    private func updateLayoutForCurrentTraitCollection() {
        collectionView.layout.interItemSpacing = 8

        switch sizeClass {
        case .hRegular_vRegular:
            collectionView.layout.numberOfColumns = 3
            collectionView.layout.numberOfRows = .fixedCount(4)
        case .hCompact_vRegular:
            collectionView.layout.numberOfColumns = 3
            collectionView.layout.numberOfRows = .fixedCount(4)
        case .hCompact_vCompact, .hRegular_vCompact:
            collectionView.layout.numberOfColumns = 6
            collectionView.layout.numberOfRows = .fixedCount(2)
        default:
            break
        }
    }

    private func contentItems() -> [String] {
        let phraseNoTitle = NSLocalizedString("preset.category.numberpad.phrase.no.title",
                                              comment: "'No' num pad response")
        let phraseYesTitle = NSLocalizedString("preset.category.numberpad.phrase.yes.title",
                                               comment: "'Yes' num pad response")

        // For this keypad layout, the 0 comes after the rest of the numbers
        let formattedNumbers = (Array(1...9) + [0]).map { intValue -> String in
            let value = NSNumber(integerLiteral: intValue)
            let formatted = NumericCategoryContentViewController.formatter.string(from: value)!
            return formatted
        }
        let responses = [phraseNoTitle, phraseYesTitle]
        return formattedNumbers + responses
    }
}
