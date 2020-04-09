//
//  CarouselGridCollectionViewController.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//
import UIKit
import Combine

typealias CarouselGridPagingProgress = (pageIndex: Int, pageCount: Int)

class CarouselGridCollectionViewController: UICollectionViewController {
    
    var progressPublisher: PublishedValue<CarouselGridPagingProgress>.Publisher {
        return layout.$progress
    }
    
    @objc func scrollToNextPage() {
        guard layout.progress.pageCount > 1 else {
            return
        }
        let nextRect = layout.nextPageRect
        collectionView.scrollRectToVisible(nextRect, animated: true)
    }
    
    @objc func scrollToPreviousPage() {
        guard layout.progress.pageCount > 1 else {
            return
        }
        let nextRect = layout.previousPageRect
        collectionView.scrollRectToVisible(nextRect, animated: true)
    }
    
    var layout: CarouselGridLayout! {
        return collectionView.collectionViewLayout as? CarouselGridLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if layout == nil {
            self.collectionView.setCollectionViewLayout(CarouselGridLayout(), animated: false)
        }
        //        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        //        layout.resetScrollViewOffset(inResponseToUserInteraction: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        layout.resetScrollViewOffset(inResponseToUserInteraction: false)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //        layout.resetScrollViewOffset(inResponseToUserInteraction: true)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //        layout.resetScrollViewOffset(inResponseToUserInteraction: true)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        if decelerate {
        //            layout.prepareForDeceleration()
        //        } else {
        //            layout.resetScrollViewOffset(inResponseToUserInteraction: true)
        //        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //        coordinator.animateAlongsideTransition(in: collectionView, animation: { [weak self] (_) in
        //            self?.layout.resetScrollViewOffset(inResponseToUserInteraction: false)
        //        }, completion: nil)
    }
    
}
class CarouselGridLayout: UICollectionViewLayout {
    
    private struct Page {
        let index: Int
        let numberOfColumns: Int
        let numberOfRows: Int
        
        private var itemsPerPage: Int {
            return numberOfRows * numberOfColumns
        }
        
        let interItemSpacing: CGFloat
        var bounds: CGRect
        var indices: NSIndexSet
        
        var allAttributes: [UICollectionViewLayoutAttributes] {
            return indices.compactMap {
                attributes(forItemAt: IndexPath(item: $0, section: 0))
            }
        }
        
        func attributes(forItemAt indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let size = bounds.size
            let width = size.width
            let height = size.height
            let index = indexPath.item
            let pageIndex = self.index
            let cellWidth = (width - CGFloat(numberOfColumns - 1) * interItemSpacing) / CGFloat(numberOfColumns)
            let cellHeight = (height - CGFloat(numberOfRows - 1) * interItemSpacing) / CGFloat(numberOfRows)
            let cellX = CGFloat((index % numberOfColumns) + (numberOfColumns * pageIndex)) * (cellWidth + interItemSpacing)
            let cellY = CGFloat(Int((index % itemsPerPage) / numberOfColumns)) * (cellHeight + interItemSpacing)
            let cellRect = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = cellRect
            return attributes
        }
        
    }
    
    private var pages: [Page] = []
    
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
    
    var nextPageRect: CGRect {
        guard let collectionView = collectionView else { return .zero }
        let visibleIndices = collectionView.indexPathsForVisibleItems.map { $0.item }
        let visiblePageIndices = pages.filter { !Set($0.indices).isDisjoint(with: visibleIndices) }.map { $0.index }
        var nextPage = visiblePageIndices.reduce(-1) { (result, nextValue) in
            return max(result, nextValue)
            } + 1
        if nextPage >= numberOfPages {
            nextPage = 0
        }
        let bounds = pages[nextPage].bounds
        return bounds
    }
    
    var previousPageRect: CGRect {
        guard let collectionView = collectionView else { return .zero }
        let visibleIndices = collectionView.indexPathsForVisibleItems.map { $0.item }
        let visiblePageIndices = pages.filter { !Set($0.indices).isDisjoint(with: visibleIndices) }.map { $0.index }
        var nextPage = visiblePageIndices.reduce(-1) { (result, nextValue) in
            return max(result, nextValue)
            } - 1
        
        if nextPage < 0 {
            nextPage = max(pages.count - 1, 0)
        }
        
        let bounds = pages[nextPage].bounds
        return bounds
    }
    
    private var itemsPerPage: Int {
        return numberOfRows * numberOfColumns
    }
    
    @PublishedValue
    var progress: CarouselGridPagingProgress = (pageIndex: 0, pageCount: 1)
    
    private var numberOfPages: Int {
        return pages.count
    }
    
    private var needsMultiplePages: Bool {
        return numberOfPages > 1
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        var size = collectionView.frame.size.applying(.init(scaleX: CGFloat(numberOfPages), y: 1))
        size.width += interItemSpacing * CGFloat(max(numberOfPages - 1, 0))
        return size
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let indicesPerPage = Array(0..<collectionView.numberOfItems(inSection: 0)).chunked(into: itemsPerPage)
        self.pages = indicesPerPage.enumerated().map { (pageIndex, indices) -> Page in
            let frame = collectionView.frame
            let pageBounds = frame.applying(.init(translationX: CGFloat(pageIndex) * frame.width + interItemSpacing * CGFloat(max(pageIndex - 1, 0)), y: 0))
            return Page(index: pageIndex,
                        numberOfColumns: self.numberOfColumns,
                        numberOfRows: self.numberOfRows,
                        interItemSpacing: self.interItemSpacing,
                        bounds: pageBounds,
                        indices: NSIndexSet(indexSet: IndexSet(indices)))
        }
        updatePageProgress()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        Array(pages.filter { page -> Bool in
            page.bounds.intersects(rect)
        }.map {
            $0.allAttributes
        }.joined())
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for page in pages where page.indices.contains(indexPath.item) {
            let attributes = page.attributes(forItemAt: indexPath)
            return attributes
        }
        return nil
    }
    
    private var lastInvalidatedSize: CGSize = .zero
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        updatePageProgress()
        defer { lastInvalidatedSize = newBounds.size }
        return lastInvalidatedSize != newBounds.size
    }
    
    private func updatePageProgress() {
        guard let collectionView = collectionView else { return }
        let visibleIndices = collectionView.indexPathsForVisibleItems.map { $0.item }
        let visiblePageIndices = pages.filter { !Set($0.indices).isDisjoint(with: visibleIndices) }.map { $0.index }
        let currentPageIndex = visiblePageIndices.reduce(0) { (result, nextValue) in
            return max(result, nextValue)
        }
        progress = (pageIndex: currentPageIndex, pageCount: numberOfPages)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) ?? self.layoutAttributesForItem(at: itemIndexPath)
        attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        return attr
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) ?? self.layoutAttributesForItem(at: itemIndexPath)
        attr?.transform = CGAffineTransform(translationX: 0, y: 500.0)
        return attr
    }
    
}

class PresetCarouselGridLayout: CarouselGridLayout {
    
}
