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
        let format = NSLocalizedString("paging_progress_indicator_format",
                                       comment: "Page indicator progress format. \"Page x of n\"")
        let formattedProgress = String.localizedStringWithFormat(format, pageIndex, pageCount)
        return formattedProgress
    }

    static let zero = CarouselGridPagingProgress(pageIndex: 0, pageCount: 0)
}

private extension CarouselGridLayout {
    static func `default`() -> CarouselGridLayout {
        let layout = CarouselGridLayout()
        layout.numberOfColumns = 2
        layout.numberOfRows = .fixedCount(3)
        layout.interItemSpacing = 24
        return layout
    }
}

@IBDesignable class CarouselGridCollectionView: UICollectionView {

    var progressPublisher: PublishedValue<CarouselGridPagingProgress>.Publisher {
        return layout.$progress
    }

    var layout: CarouselGridLayout {
        return self.collectionViewLayout as! CarouselGridLayout
    }

    private var lastInvalidatedSize: CGSize = .zero
    override var frame: CGRect {
        didSet {
            guard window != nil, frame.size != lastInvalidatedSize else { return }
            snapToBoundaryIfNeeded()
        }
    }

    private var needsInitialScrollToMiddle = true

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
        if let indexPath = layout.firstIndexPathForPageWithOffsetFromCurrentPage(offset: 1) {
            scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }

    @objc func scrollToPreviousPage() {
        if let indexPath = layout.firstIndexPathForPageWithOffsetFromCurrentPage(offset: -1) {
            scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if needsInitialScrollToMiddle {
            scrollToMiddleSection()
            needsInitialScrollToMiddle = false
        }
    }

    func scrollToMiddleSection() {
        let sectionCount = numberOfSections
        scrollToItem(at: IndexPath(item: 0, section: sectionCount / 2),
                     at: .left,
                     animated: false)
        layoutIfNeeded()
    }

    private func snapToBoundaryIfNeeded() {
        guard !isDecelerating, !isDragging, !isTracking else { return }
        scrollToNearestSelectedIndexPathOrCurrentPageBoundary()
    }

    private func scrollToNearestSelectedIndexPathOrCurrentPageBoundary(animated: Bool = false) {
        let selectedIndexPaths = indexPathsForSelectedItems ?? []

        let destination: IndexPath
        if let middleIndexPath = selectedIndexPaths[safe: selectedIndexPaths.count / 2], let target = layout.indexPathForLeftmostCellOfPage(containing: middleIndexPath) {
            destination = target
        } else
            if let target = animated ? layout.indexPathForLeftmostCellOfCurrentPage() : layout.indexPathForLeftmostCellOfCurrentPageInMiddleSection() {
            destination = target
        } else {
            return
        }

        scrollToItem(at: destination,
                     at: .left,
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
