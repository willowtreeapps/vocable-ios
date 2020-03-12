//
//  ViewController.swift
//  YouScrollMeRightRound
//
//  Created by Chris Stroud on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

typealias CarouselGridPagingProgress = (pageIndex: Int, pageCount: Int)

class CarouselGridCollectionViewController: UICollectionViewController {

    // Prototype content -- delete after Core Data is integrated

    private lazy var _prototypeDiffableDataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView!) { (collectionView, indexPath, _) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditSayingsCollectionViewCell.reuseIdentifier, for: indexPath) as! EditSayingsCollectionViewCell
        cell.setup(title: "\(indexPath.item)")
        return cell
    }

    private func _prototypeSetupDataSource() {
        var snap = _prototypeDiffableDataSource.snapshot()
        snap.appendSections([0])
        snap.appendItems(Array(0...12))
        _prototypeDiffableDataSource.apply(snap, animatingDifferences: false)
    }

    private func _prototypeDeleteItem(at indexPath: IndexPath) {
        guard let item = _prototypeDiffableDataSource.itemIdentifier(for: indexPath) else { return }
        var snapshot = _prototypeDiffableDataSource.snapshot()
        snapshot.deleteItems([item])
        _prototypeDiffableDataSource.apply(snapshot, animatingDifferences: true, completion: { [weak self] in
            self?.layout.invalidateLayout()
            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false, animateIfNeeded: true)
        })
    }

    // End prototype content

    var progressPublisher: Published<CarouselGridPagingProgress?>.Publisher {
        return layout.$progress
    }

    func scrollToNextPage() {
        let nextRect = layout.nextPageRect
        collectionView.scrollRectToVisible(nextRect, animated: true)
    }

    func scrollToPreviousPage() {
        let nextRect = layout.previousPageRect
        collectionView.scrollRectToVisible(nextRect, animated: true)
    }

    let layout: CarouselGridLayout = {
        let layout = CarouselGridLayout()
        layout.numberOfColumns = 2
        layout.numberOfRows = 3
        layout.interItemSpacing = 24
        return layout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.setCollectionViewLayout(self.layout, animated: false)
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "EditSayingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EditSayingsCollectionViewCell")
        collectionView.backgroundColor = .collectionViewBackgroundColor
    
        _prototypeSetupDataSource()

        layout.resetScrollViewOffset(inResponseToUserInteraction: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layout.resetScrollViewOffset(inResponseToUserInteraction: false)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _prototypeDeleteItem(at: indexPath)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        layout.resetScrollViewOffset(inResponseToUserInteraction: true)
    }

    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        layout.resetScrollViewOffset(inResponseToUserInteraction: true)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            layout.prepareForDeceleration()
        } else {
            layout.resetScrollViewOffset(inResponseToUserInteraction: true)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: collectionView, animation: { [weak self] (_) in
            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false)
        }, completion: nil)
    }
}

class CarouselGridLayout: UICollectionViewLayout {

    var numberOfColumns = 1 {
        didSet {
            if numberOfColumns < 1 {
                numberOfColumns = 1
            }
            invalidateLayout()
        }
    }

    var numberOfRows = 1 {
        didSet {
            if numberOfRows < 1 {
                numberOfRows = 1
            }
            invalidateLayout()
        }
    }

    var interItemSpacing: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }

    private var itemsPerPage: Int {
        return numberOfRows * numberOfColumns
    }

    private var logicalPageIndex: Int = 0 {
        didSet {
            if logicalPageIndex == -1 {
                logicalPageIndex = numberOfPages - 1
            } else if logicalPageIndex == numberOfPages {
                logicalPageIndex = 0
            }
            self.progress = (pageIndex: logicalPageIndex, pageCount: numberOfPages)
        }
    }

    @Published
    var progress: CarouselGridPagingProgress?

    private var numberOfPages: Int {
        guard let collectionView = collectionView else { return 1 }
        let pageCount = Int((Double(collectionView.numberOfItems(inSection: 0)) / Double(itemsPerPage)).rounded(.up))
        if pageCount != (progress?.pageCount ?? 0) {
            progress = (pageIndex: logicalPageIndex, pageCount: pageCount)
        }
        return pageCount
    }

    private var needsMultiplePages: Bool {
        return numberOfPages > 1
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        if !needsMultiplePages {
            return collectionView.frame.size
        }
        var size = collectionView.frame.size.applying(.init(scaleX: 3, y: 1))
        size.width += interItemSpacing * 2
        return size
    }

    var currentPageScrollOffset: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let restingBounds = boundsRectForPageIndex(1)
        let offset = CGSize(width: collectionView.bounds.origin.x - restingBounds.origin.x,
                            height: collectionView.bounds.origin.y - restingBounds.origin.y)
        return offset
    }

    private var resetRect: CGRect {
        guard let collectionView = collectionView else { return .zero }
        let bounds = collectionView.bounds
        let resetRect = CGRect(origin: .init(x: bounds.width + interItemSpacing, y: 0), size: bounds.size)
        return resetRect
    }

    fileprivate var nextPageRect: CGRect {
        let resetRect = self.resetRect
        let rect = resetRect.applying(.init(translationX: resetRect.width + interItemSpacing, y: 0))
        return rect
    }

    fileprivate var previousPageRect: CGRect {
        let resetRect = self.resetRect
        let rect = resetRect.applying(.init(translationX: -(resetRect.width + interItemSpacing), y: 0))
        return rect
    }

    func prepareForDeceleration() {
        collectionView?.isUserInteractionEnabled = false
    }

    func resetScrollViewOffset(inResponseToUserInteraction: Bool = true, animateIfNeeded: Bool = false) {
        guard let collectionView = collectionView else { return }

        // Handles the case of the last item being deleted from the visible page
        if logicalPageIndex >= numberOfPages {
            let rect = boundsRectForPageIndex(-1)
            collectionView.scrollRectToVisible(rect, animated: animateIfNeeded)
            logicalPageIndex -= 1
            return
        }

        let currentOffset = currentPageScrollOffset.width
        if inResponseToUserInteraction && abs(currentOffset) > collectionView.frame.width / 2.0 {
            let offsetSign = Int(currentOffset / abs(currentOffset))
            logicalPageIndex += offsetSign
        }
        collectionView.scrollRectToVisible(resetRect, animated: animateIfNeeded)
        collectionView.isUserInteractionEnabled = true
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    private func boundsRectForPageIndex(_ index: Int) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        let size = collectionView.bounds.size
        let origin = CGPoint(x: CGFloat(index) * (size.width + interItemSpacing), y: 0)
        let rect = CGRect(origin: origin, size: size)
        return rect
    }

    private func frameForCellAtIndex(_ index: Int) -> CGRect {
        guard let collectionView = collectionView else { return .zero }
        let size = collectionView.bounds.size
        let width = size.width
        let height = size.height

        let itemsPerPage = numberOfRows * numberOfColumns

        let pageIndex = index / itemsPerPage

        let cellWidth = (width - CGFloat(numberOfColumns - 1) * interItemSpacing) / CGFloat(numberOfColumns)
        let cellHeight = (height - CGFloat(numberOfRows - 1) * interItemSpacing) / CGFloat(numberOfRows)

        let cellX = CGFloat((index % numberOfColumns) + (numberOfColumns * pageIndex)) * (cellWidth + interItemSpacing)
        let cellY = CGFloat(Int((index % itemsPerPage) / numberOfColumns)) * (cellHeight + interItemSpacing)

        let cellRect = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
        return cellRect
    }

    private func pageIndex(before previousIndex: Int) -> Int? {
        var proposedIndex = logicalPageIndex - 1
        if proposedIndex == -1 {
            proposedIndex = numberOfPages - 1
        }
        if proposedIndex == previousIndex {
            return nil
        }
        return proposedIndex
    }

    private func pageIndex(after previousIndex: Int) -> Int? {
        var proposedIndex = logicalPageIndex + 1
        if proposedIndex == numberOfPages {
            proposedIndex = 0
        }
        if proposedIndex == previousIndex {
            return nil
        }
        return proposedIndex
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        if !needsMultiplePages {
            return layoutAttributesForElementsInLogicalPage(logicalPageIndex, offsetByPageCount: -1)
        }

        let currentPageAttributes = layoutAttributesForElementsInLogicalPage(logicalPageIndex)

        let leftwardPageAttributes: [UICollectionViewLayoutAttributes]
        if currentPageScrollOffset.width < 0, let leftwardIndex = pageIndex(before: logicalPageIndex) {
            leftwardPageAttributes = layoutAttributesForElementsInLogicalPage(leftwardIndex, offsetByPageCount: -1)
        } else {
            leftwardPageAttributes = []
        }

        let rightwardPageAttributes: [UICollectionViewLayoutAttributes]
        if currentPageScrollOffset.width > 0, let rightwardIndex = pageIndex(after: logicalPageIndex) {
            rightwardPageAttributes = layoutAttributesForElementsInLogicalPage(rightwardIndex, offsetByPageCount: 1)
        } else {
            rightwardPageAttributes = []
        }

        let attributes = Array([leftwardPageAttributes, currentPageAttributes, rightwardPageAttributes].joined())
        return attributes
    }

    private func layoutAttributesForElementsInLogicalPage(_ index: Int, offsetByPageCount offsetPageCount: Int = 0) -> [UICollectionViewLayoutAttributes] {

        guard let collectionView = collectionView else { return [] }

        let portalRect = boundsRectForPageIndex(index)
        let tx = collectionView.bounds.origin.x.distance(to: portalRect.origin.x) - CGFloat(offsetPageCount) * (collectionView.bounds.width + interItemSpacing) + currentPageScrollOffset.width

        let startIndex = itemsPerPage * index
        let endIndex = max(min(startIndex + itemsPerPage, collectionView.numberOfItems(inSection: 0)), 0)

        let attributes = (startIndex ..< endIndex).map { index -> UICollectionViewLayoutAttributes in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attributes.frame = frameForCellAtIndex(index).applying(.init(translationX: -tx, y: 0))
            return attributes
        }
        return attributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        let width = collectionView.bounds.width
        let index = (proposedContentOffset.x / (width + interItemSpacing)).rounded()
        let boundary = boundsRectForPageIndex(Int(index))
        return boundary.origin
    }
}
