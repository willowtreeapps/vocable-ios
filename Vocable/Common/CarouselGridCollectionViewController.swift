//
//  CarouselGridCollectionViewController.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

struct CarouselGridPagingProgress {
    var pageIndex: Int
    var pageCount: Int
    var localizedString: String {
        let pageIndex = max(self.pageIndex + 1, 1)
        let pageCount = max(self.pageCount, 1)
        let format = Localization.pagingProgressIndicatorFormat(pageIndex, pageCount)
        let formattedProgress = String.localizedStringWithFormat(format, pageIndex, pageCount)
        return formattedProgress
    }

    static let zero = CarouselGridPagingProgress(pageIndex: 0, pageCount: 0)
}

private extension CarouselGridLayout {
    static func `default`() -> CarouselGridLayout {
        let layout = CarouselGridLayout()
        layout.numberOfColumns = .fixedCount(2)
        layout.numberOfRows = .fixedCount(3)
        layout.interItemSpacing = .uniform(24)
        return layout
    }
}

class CarouselGridCollectionView: UICollectionView {

    var progressPublisher: PublishedValue<CarouselGridPagingProgress>.Publisher {
        return layout.$progress
    }

    var layout: CarouselGridLayout {
        return self.collectionViewLayout as! CarouselGridLayout
    }

    private var needsInitialScrollToMiddle = true

    private var lastInvalidatedFrameSize: CGSize = .zero
    override var frame: CGRect {
        didSet {
            guard frame.size != lastInvalidatedFrameSize, !needsInitialScrollToMiddle else {
                return
            }
            snapToBoundaryIfNeeded()
            lastInvalidatedFrameSize = frame.size
        }
    }

    private var lastInvalidatedContentSize: CGSize = .zero
    override var contentSize: CGSize {
        didSet {
            defer {
                if !needsInitialScrollToMiddle {
                    lastInvalidatedContentSize = contentSize
                }
            }
            guard contentSize != lastInvalidatedContentSize else { return }
            if needsInitialScrollToMiddle {
                layoutIfNeeded()
                needsInitialScrollToMiddle = !scrollToMiddleSection(animated: false)
            } else {
                snapToBoundaryIfNeeded()
            }
        }
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    init() {
        super.init(frame: .zero, collectionViewLayout: CarouselGridLayout.default())
        commonInit()
    }

    private func commonInit() {
        decelerationRate = .fast
        isPagingEnabled = false
        contentInsetAdjustmentBehavior = .never
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delaysContentTouches = false
        allowsMultipleSelection = true
        backgroundColor = .collectionViewBackgroundColor
    }

    @objc func scrollToNextPage() {
        if needsInitialScrollToMiddle {
            scrollToMiddleSection(animated: false)
            needsInitialScrollToMiddle = false
        }
        if let offset = layout.scrollOffsetForPageWithOffsetFromCurrentPage(offset: 1) {
            let shouldAnimate = UIView.areAnimationsEnabled
            scrollRectToVisible(CGRect(origin: offset, size: bounds.size), animated: shouldAnimate)
        }
    }

    @objc func scrollToPreviousPage() {
        if needsInitialScrollToMiddle {
            scrollToMiddleSection(animated: false)
            needsInitialScrollToMiddle = false
        }
        if let offset = layout.scrollOffsetForPageWithOffsetFromCurrentPage(offset: -1) {
            let shouldAnimate = UIView.areAnimationsEnabled
            scrollRectToVisible(CGRect(origin: offset, size: bounds.size), animated: shouldAnimate)
        }
    }

    @discardableResult
    func scrollToMiddleSection(animated: Bool) -> Bool {

        guard let offset = layout.scrollOffsetForLeftmostCellOfCurrentPageInMiddleSection() else {
            return false
        }
        scrollRectToVisible(CGRect(origin: offset, size: bounds.size), animated: animated)
        if !animated {
            layoutIfNeeded()
        }
        return true
    }

    private func snapToBoundaryIfNeeded() {
        guard !isDecelerating, !isDragging, !isTracking else { return }
        scrollToNearestSelectedIndexPathOrCurrentPageBoundary()
    }

    func scrollToNearestSelectedIndexPathOrCurrentPageBoundary(animated: Bool = false) {
        let selectedIndexPaths = indexPathsForSelectedItems ?? []
        let destination: CGPoint
        if let middleIndexPath = selectedIndexPaths[safe: selectedIndexPaths.count / 2], let target = layout.scrollOffsetForLeftmostCellOfPage(containing: middleIndexPath) {
            destination = target
        } else
            if let target = animated ? layout.scrollOffsetForLeftmostCellOfCurrentPage() : layout.scrollOffsetForLeftmostCellOfCurrentPageInMiddleSection() {
            destination = target
        } else {
            return
        }

        scrollRectToVisible(CGRect(origin: destination, size: bounds.size),
                            animated: animated)
        if !animated {
            layoutIfNeeded()
        }
    }
}

class CarouselGridCollectionViewController: UICollectionViewController {

    var progressPublisher: PublishedValue<CarouselGridPagingProgress>.Publisher {
        return carouselCollectionView.progressPublisher
    }

    var carouselCollectionView: CarouselGridCollectionView {
        return self.collectionView as! CarouselGridCollectionView
    }

    override func loadView() {
        let collectionView = CarouselGridCollectionView()
        self.collectionView = collectionView
    }

    @objc func scrollToNextPage() {
        carouselCollectionView.scrollToNextPage()
    }

    @objc func scrollToPreviousPage() {
        carouselCollectionView.scrollToPreviousPage()
    }

    var layout: CarouselGridLayout {
        return carouselCollectionView.layout
    }

    init() {
        super.init(collectionViewLayout: CarouselGridLayout.default())
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
