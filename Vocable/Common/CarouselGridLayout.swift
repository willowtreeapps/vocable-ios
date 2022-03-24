//
//  CarouselGridLayout.swift
//  Vocable
//
//  Created by Chris Stroud on 4/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class CarouselGridLayout: UICollectionViewLayout {

    fileprivate enum SizingAxis {
        case horizontal
        case vertical
    }
    
    enum SizingValue: Equatable {
        case absolute(CGFloat)
        case relative(CGFloat)

        fileprivate func value(from rect: CGRect, axis: SizingAxis) -> CGFloat {
            switch axis {
            case .horizontal:
                switch self {
                case .absolute(let fixed):
                    return fixed
                case .relative(let relative):
                    return rect.width * relative + rect.minX
                }
            case .vertical:
                switch self {
                case .absolute(let fixed):
                    return fixed
                case .relative(let relative):
                    return rect.height * relative + rect.minY
                }
            }
        }
    }

    enum RowCount: Equatable {
        case fixedCount(Int, maxHeight: SizingValue = .relative(1.0))
        case flexible(minHeight: SizingValue = .absolute(0), maxHeight: SizingValue = .relative(1.0))
    }

    enum ColumnCount: Equatable {
        case fixedCount(Int)
        case minimumWidth(CGFloat)
    }

    enum ItemAnimationStyle {
        case none
        case shrinkExpand
        case verticalTimeline
    }

    enum VerticalAlignment {
        case top
        case center
        case bottom
    }

    var alignment: VerticalAlignment = .top {
        didSet {
            guard oldValue != alignment else { return }
            invalidateItemAttributesForParameterChange()
        }
    }

    var itemAnimationStyle: ItemAnimationStyle = .none

    var numberOfColumns: ColumnCount = .fixedCount(1) {
        didSet {
            guard oldValue != numberOfColumns else {
                return
            }

            invalidateItemAttributesForParameterChange()
        }
    }

    var numberOfRows: RowCount = .fixedCount(1) {
        didSet {
            guard oldValue != numberOfRows else {
                return
            }

            invalidateItemAttributesForParameterChange()
        }
    }

    var interItemSpacing: CGFloat = 0 {
        didSet {
            guard oldValue != interItemSpacing else { return }
            invalidateItemAttributesForParameterChange()
        }
    }

    var pageInsets: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != pageInsets else { return }
            invalidateItemAttributesForParameterChange()
        }
    }

    var itemsPerPage: Int {
        return rowCount * columnCount
    }

    @PublishedValue
    var progress: CarouselGridPagingProgress = .zero

    private(set) var rowCount: Int = 1
    private(set) var columnCount: Int = 1

    private var itemsPerSection: Int {
        guard numberOfSections > 0, let count = collectionView?.numberOfItems(inSection: 0) else {
            return 0
        }
        return count
    }

    private var sectionContentSize: CGSize {
        var size = pageContentSize
        size = size.applying(.init(scaleX: CGFloat(pagesPerSection), y: 1))
        return size
    }

    private var pageContentSize: CGSize {
        return collectionView?.bounds.size ?? .zero
    }

    private var numberOfSections: Int {
        let count = collectionView?.numberOfSections ?? 0
        return count
    }

    var pagesPerSection: Int {
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
            pageContentSize.width > 0 else { return 0 }
        let index = Int(collectionView.bounds.midX / pageContentSize.width)
        return index
    }

    override var collectionViewContentSize: CGSize {
        let size = sectionContentSize.applying(.init(scaleX: CGFloat(numberOfSections), y: 1))
        return size
    }

    private var lastDataSourceProxyInvalidationCount = 0
    private var lastLayoutSize: CGSize = .zero
    override func prepare() {
        super.prepare()
        lastLayoutSize = collectionView?.frame.size ?? .zero

        columnCount = computeColumnCount()
        rowCount = computeRowCount()

        updatePagingProgress()

        if lastDataSourceProxyInvalidationCount != itemsPerPage {
            if let proxyAction = (collectionView as? CarouselGridCollectionView)?.dataSourceProxyInvalidationCallback {
                proxyAction()
            }
            lastDataSourceProxyInvalidationCount = itemsPerPage
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        updatePagingProgress()
        return lastLayoutSize != newBounds.size
    }

    private func invalidateItemAttributesForParameterChange() {
        let invalidationContext = UICollectionViewFlowLayoutInvalidationContext()
        invalidationContext.invalidateFlowLayoutAttributes = true
        invalidateLayout(with: invalidationContext)
    }

    private func computeColumnCount() -> Int {
        switch numberOfColumns {
        case .fixedCount(let count):
            return count
        case .minimumWidth(let minimumWidth):
            guard let width = collectionView?.bounds.width, width > 0 else {
                return 1
            }
            var itemCount = Int(width / minimumWidth)
            while itemCount > 0 {
                let interItemWidth = CGFloat(itemCount - 1) * interItemSpacing
                let availableWidth = width - interItemWidth
                if (availableWidth / CGFloat(itemCount)) >= minimumWidth {
                    break
                }
                itemCount -= 1
            }
            if itemCount == 0 {
                assertionFailure("interItemSpacing (\(interItemSpacing)) and numberOfColumns(.minimumWidth(\(minimumWidth))) could not be resolved")
            }
            return itemCount
        }
    }

    private func computeRowCount() -> Int {
        switch numberOfRows {
        case .fixedCount(let count, _):
            return count
        case .flexible(let minimumHeight, _):
            guard let height = collectionView?.bounds.height, height > 0 else {
                return 1
            }
            let minHeightValue = minimumHeight.value(from: collectionView?.bounds ?? .zero, axis: .vertical)
            var itemCount = Int(height / minHeightValue)
            while itemCount > 0 {
                let interItemHeight = CGFloat(itemCount - 1) * interItemSpacing
                let availableHeight = height - interItemHeight
                if (availableHeight / CGFloat(itemCount)) >= minHeightValue {
                    break
                }
                itemCount -= 1
            }
            if itemCount == 0 {
                assertionFailure("interItemSpacing (\(interItemSpacing)) and numberOfRows(.minimumHeight(\(minimumHeight))) could not be resolved")
            }
            return itemCount
        }
    }

    private func frameForCell(at indexPath: IndexPath, additionalPageInsets: UIEdgeInsets = .zero, pageOffset: UIOffset = .zero, interItemSpacing: CGFloat? = nil) -> CGRect {

        guard itemsPerPage > 0 else { return .zero }

        let interItemSpacing = interItemSpacing ?? self.interItemSpacing
        let pageRect: CGRect = rectForPage(containing: indexPath).offsetBy(dx: pageOffset.horizontal, dy: pageOffset.vertical)

        let contentRect = pageRect.inset(by: pageInsets + additionalPageInsets)
        let cellColumnIndex = indexPath.item % columnCount
        let cellRowIndex = (indexPath.item % itemsPerPage) / columnCount

        let totalInterItemSpace = CGSize(width: CGFloat(columnCount - 1) * interItemSpacing,
                                         height: CGFloat(rowCount - 1) * interItemSpacing)

        let maximumAvailableCellHeight = (contentRect.height - totalInterItemSpace.height) / CGFloat(rowCount)
        let cellWidth = (contentRect.width - totalInterItemSpace.width) / CGFloat(columnCount)
        var cellHeight = maximumAvailableCellHeight

        switch numberOfRows {
        case .fixedCount(_, maxHeight: let maxHeight):
            let _max = maxHeight.value(from: contentRect, axis: .vertical)
            cellHeight = min(min(cellHeight, _max), maximumAvailableCellHeight)
        case .flexible(let minHeight, let maxHeight):
            let _min = minHeight.value(from: contentRect, axis: .vertical)
            let _max = maxHeight.value(from: contentRect, axis: .vertical)
            cellHeight = min(min(max(cellHeight, _min), _max), maximumAvailableCellHeight)
        }

        let cellContentOffset: UIOffset = {

            let numberOfItemsInPage: Int = {
                let totalNumberOfItems = collectionView?.numberOfItems(inSection: indexPath.section) ?? 0
                switch numberOfRows {
                case .fixedCount:
                    return itemsPerPage
                case .flexible:
                    return min(totalNumberOfItems - ((indexPath.item / itemsPerPage) * itemsPerPage), itemsPerPage)
                }
            }()
            let numberOfOccupiedRows = (CGFloat(numberOfItemsInPage) / CGFloat(columnCount)).rounded(.up)
            let occupiedInterItemSpace = CGSize(width: CGFloat(columnCount - 1) * interItemSpacing,
                                                height: CGFloat(numberOfOccupiedRows - 1) * interItemSpacing)
            var size = CGSize.zero
            size.width = cellWidth * CGFloat(columnCount) + occupiedInterItemSpace.width
            size.height = cellHeight * CGFloat(numberOfOccupiedRows) + occupiedInterItemSpace.height

            var origin = CGPoint.zero
            switch alignment {
            case .top:
                origin.y = 0
                origin.x = max((contentRect.width - size.width) / 2, 0)
            case .bottom:
                origin.y = max(contentRect.height - size.height, 0)
                origin.x = max((contentRect.width - size.width) / 2, 0)
            case .center:
                origin.y = max((contentRect.height - size.height) / 2, 0)
                origin.x = max((contentRect.width - size.width) / 2, 0)
            }
            let offset = UIOffset(horizontal: origin.x, vertical: origin.y)
            return offset
        }()

        let cellX = CGFloat(cellColumnIndex) * (cellWidth + interItemSpacing) + cellContentOffset.horizontal
        let cellY = CGFloat(cellRowIndex) * (cellHeight + interItemSpacing) + cellContentOffset.vertical

        let cellRect = CGRect(x: contentRect.minX + cellX,
                              y: contentRect.minY + cellY,
                              width: cellWidth,
                              height: cellHeight)
        return cellRect
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView, sectionContentSize.area > 0, numberOfSections > 0 else {
            return nil
        }
        var items = [UICollectionViewLayoutAttributes]()

        let section = Int(rect.midX / sectionContentSize.width)
        let sections = [section, section + 1, section - 1].filter((0..<numberOfSections).contains)

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
        let attr = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attr.frame = frameForCell(at: indexPath)
        attr.alpha = 1
        attr.transform = .identity
        return attr
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let superAttributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        if itemAnimationStyle == .shrinkExpand {
            superAttributes.transform = superAttributes.transform.scaledBy(x: 0.8, y: 0.8)
            superAttributes.alpha = 0.0
            superAttributes.frame = frameForCell(at: itemIndexPath)
        }

        return superAttributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let superAttributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes else { return nil }
        if itemAnimationStyle == .shrinkExpand {
            superAttributes.transform = superAttributes.transform.scaledBy(x: 0.8, y: 0.8)
            superAttributes.alpha = 0.0
        }
        return superAttributes
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

        let pageIndex = Int((proposedCenterX / pageContentSize.width))
        let sectionIndex = pageIndex / pagesPerSection
        let pageIndexInSection = pageIndex % pagesPerSection
        let firstItemInPage = pageIndexInSection * itemsPerPage
        let indexPath = IndexPath(item: firstItemInPage, section: sectionIndex)
        return targetScrollOffsetForItem(at: indexPath)
    }

    private func rectForPage(containing indexPath: IndexPath) -> CGRect {
        let pageIndexWithinSection = Int(indexPath.item / itemsPerPage)
        let globalPageIndex = indexPath.section * pagesPerSection + pageIndexWithinSection
        let origin = CGPoint(x: CGFloat(globalPageIndex) * pageContentSize.width, y: 0)
        return CGRect(origin: origin, size: pageContentSize)
    }

    private func targetScrollOffsetForItem(at indexPath: IndexPath) -> CGPoint {
        return rectForPage(containing: indexPath).origin
    }

    func scrollOffsetForPageWithOffsetFromCurrentPage(offset: Int) -> CGPoint? {

        let pageIndex = currentPageIndex + offset
        guard (0..<numberOfPages).contains(pageIndex), pagesPerSection > 0 else {
            return nil
        }
        let sectionIndex = pageIndex / pagesPerSection
        let pageIndexInSection = pageIndex % pagesPerSection
        let firstItemInPage = pageIndexInSection * itemsPerPage
        let indexPath = IndexPath(item: firstItemInPage, section: sectionIndex)
        return targetScrollOffsetForItem(at: indexPath)
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

    func scrollOffsetForLeftmostCellOfPage(containing indexPath: IndexPath, inMiddleSection: Bool = false) -> CGPoint? {
        guard pagesPerSection > 0, itemsPerPage > 0 else {
            return nil
        }
        
        let pageOfIndexPathWithinSection = indexPath.item / itemsPerPage
        let firstItemInPage = pageOfIndexPathWithinSection * itemsPerPage
        let section = inMiddleSection ? (numberOfSections / 2) : indexPath.section
        let indexPath = IndexPath(item: firstItemInPage, section: section)
        return targetScrollOffsetForItem(at: indexPath)
    }
    
    func scrollOffsetForLeftmostCellOfCurrentPage() -> CGPoint? {
        let indexPaths = collectionView?.indexPathsForVisibleItems ?? []
        if let centerIndexPath = indexPaths[safe: indexPaths.count / 2] {
            let offset = scrollOffsetForLeftmostCellOfPage(containing: centerIndexPath)
            return offset
        }
        return nil
    }

    func scrollOffsetForLeftmostCellOfCurrentPageInMiddleSection() -> CGPoint? {
        if let visibleIndexPaths = collectionView?.indexPathsForVisibleItems {
            if let centerIndexPath = visibleIndexPaths[safe: visibleIndexPaths.count / 2] {
                if let result = scrollOffsetForLeftmostCellOfPage(containing: centerIndexPath, inMiddleSection: true) {
                    return result
                }
            }
        }
        return nil
    }
}
