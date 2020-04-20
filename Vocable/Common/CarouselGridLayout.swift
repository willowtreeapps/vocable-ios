//
//  CarouselGridLayout.swift
//  Vocable
//
//  Created by Chris Stroud on 4/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class CarouselGridLayout: UICollectionViewLayout {

    enum RowCount {
        case fixedCount(Int)
        case minimumHeight(CGFloat)
    }

    var numberOfColumns = 1 {
        didSet {
            guard oldValue != numberOfColumns else {
                return
            }
            if numberOfColumns < 1 {
                numberOfColumns = 1
            }
            invalidateLayout()
        }
    }

    var numberOfRows: RowCount = .fixedCount(1) {
        didSet {
            switch (oldValue, numberOfRows) {
            case (.fixedCount(let countA), .fixedCount(let countB)):
                if countA == countB {
                    return
                }
            case (.minimumHeight(let heightA), .minimumHeight(let heightB)):
                if heightA == heightB {
                    return
                }
            case (_, _):
                break
            }
            invalidateLayout()
        }
    }

    var interItemSpacing: CGFloat = 0 {
        didSet {
            guard oldValue != interItemSpacing else { return }
            invalidateLayout()
        }
    }

    var itemsPerPage: Int {
        return rowCount * numberOfColumns
    }

    @PublishedValue
    var progress: CarouselGridPagingProgress = .zero

    private var transitioningDelegate: VocableCollectionViewLayoutTransitioningDelegate? {
        return collectionView?.delegate as? VocableCollectionViewLayoutTransitioningDelegate
    }

    private var rowCount: Int {
        switch numberOfRows {
        case .fixedCount(let count):
            return count
        case .minimumHeight(let minimumHeight):
            return Int((collectionView?.bounds.height ?? 0) / minimumHeight)
        }
    }

    private var itemsPerSection: Int {
        guard numberOfSections > 0, let count = collectionView?.numberOfItems(inSection: 0) else {
            return 0
        }
        return count
    }

    private var sectionContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        var size = collectionView.bounds.size
        size.width += interItemSpacing
        size = size.applying(.init(scaleX: CGFloat(pagesPerSection), y: 1))
        return size
    }

    private var pageContentSize: CGSize {
        let size = collectionView?.bounds.size ?? .zero
        return size
    }

    private var numberOfSections: Int {
        let count = collectionView?.numberOfSections ?? 0
        return count
    }

    private var pagesPerSection: Int {
        guard itemsPerPage > 0 else { return 0 }
        let count = Int((Double(itemsPerSection) / Double(itemsPerPage)).rounded(.awayFromZero))
        return count
    }

    private var numberOfPages: Int {
        let count = pagesPerSection * numberOfSections
        return count
    }

    private var currentPageIndex: Int {
        guard let collectionView = collectionView,
            pageContentSize.width > 0 || interItemSpacing > 0 else { return 0 }
        let index = Int((collectionView.bounds.midX / (pageContentSize.width + interItemSpacing)))
        return index
    }

    override var collectionViewContentSize: CGSize {
        var size = sectionContentSize.applying(.init(scaleX: CGFloat(numberOfSections), y: 1))
        size.width -= interItemSpacing // The last page does not have trailing padding
        return size
    }

    private var lastLayoutSize: CGSize = .zero
    override func prepare() {
        super.prepare()
        lastLayoutSize = collectionView?.frame.size ?? .zero
        updatePagingProgress()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        updatePagingProgress()
        return lastLayoutSize != newBounds.size
    }

    private func frameForCell(at indexPath: IndexPath) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        let size = collectionView.bounds.size
        let width = size.width
        let height = size.height
        let xOffset = CGFloat(indexPath.section) * sectionContentSize.width

        let itemsPerPage = rowCount * numberOfColumns
        guard itemsPerPage > 0 else { return .zero }

        let pageIndex = indexPath.item / itemsPerPage

        let cellWidth = (width - CGFloat(numberOfColumns - 1) * interItemSpacing) / CGFloat(numberOfColumns)
        let cellHeight = (height - CGFloat(rowCount - 1) * interItemSpacing) / CGFloat(rowCount)

        let cellX = CGFloat((indexPath.item % numberOfColumns) + (numberOfColumns * pageIndex)) * (cellWidth + interItemSpacing)
        let cellY = CGFloat(Int((indexPath.item % itemsPerPage) / numberOfColumns)) * (cellHeight + interItemSpacing)

        let cellRect = CGRect(x: xOffset + cellX, y: cellY, width: cellWidth, height: cellHeight)
        return cellRect
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView, sectionContentSize.area > 0, numberOfSections > 0 else {
            return nil
        }
        var items = [UICollectionViewLayoutAttributes]()

        let section = Int(rect.midX / sectionContentSize.width)
        let sections = [section, section + 1, section - 1].filter { (0..<numberOfSections).contains($0)
        }

        for section in sections {
            let itemCountForSection = collectionView.numberOfItems(inSection: section)
            for index in 0..<itemCountForSection {
                if let attr = layoutAttributesForItem(at: IndexPath(item: index, section: section)) {
                    items.append(attr)
                }
            }
        }
        return items
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.layoutAttributesForItem(at: indexPath) ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attr.frame = frameForCell(at: indexPath)
        return attr
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, pagesPerSection > 0,
            pageContentSize.width > 0 || interItemSpacing > 0 else { return proposedContentOffset }
        let proposedCenterX: CGFloat
        if velocity.x > 1.0 {
            proposedCenterX = collectionView.bounds.maxX
        } else if velocity.x < -1.0 {
            proposedCenterX = collectionView.bounds.minX
        } else {
            proposedCenterX = collectionView.bounds.midX
        }

        let pageIndex = Int((proposedCenterX / (pageContentSize.width + interItemSpacing)))
        let sectionIndex = pageIndex / pagesPerSection
        let pageIndexInSection = pageIndex % pagesPerSection
        let firstItemInPage = pageIndexInSection * itemsPerPage
        let rect = frameForCell(at: IndexPath(item: firstItemInPage, section: sectionIndex))
        return rect.origin
    }

    func firstIndexPathForPageWithOffsetFromCurrentPage(offset: Int) -> IndexPath? {

        let pageIndex = currentPageIndex + offset
        guard (0..<numberOfPages).contains(pageIndex), pagesPerSection > 0 else {
            return nil
        }
        let sectionIndex = pageIndex / pagesPerSection
        let pageIndexInSection = pageIndex % pagesPerSection
        let firstItemInPage = pageIndexInSection * itemsPerPage
        let indexPath = IndexPath(item: firstItemInPage, section: sectionIndex)
        return indexPath
    }

    private func updatePagingProgress() {
        guard pagesPerSection > 0 else {
            progress = .zero
            return
        }
        let index = currentPageIndex % pagesPerSection
        let count = pagesPerSection
        if progress.pageIndex == index, progress.pageCount == count {
            return
        }
        progress = .init(pageIndex: index, pageCount: count)
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        guard let collectionView = collectionView else {
            return attr
        }

        let shouldTranslate = transitioningDelegate?.collectionView?(collectionView,
                                                        shouldTranslateEntranceAnimationForItemAt: itemIndexPath) ?? false
        if shouldTranslate {
            attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        } else {
            attr?.transform = .identity
        }

        return attr
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)

        guard let collectionView = collectionView else {
            return attr
        }

        let shouldTranslate = transitioningDelegate?.collectionView?(collectionView,
                                                        shouldTranslateExitAnimationForItemAt: itemIndexPath) ?? false
        if shouldTranslate {
            attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        } else {
            attr?.transform = .identity
        }

        return attr
    }
}
