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
        let pageIndex = self.pageIndex + 1
        let pageCount = self.pageCount
        let format = NSLocalizedString("paging_progress_indicator_format",
                                       comment: "Page indicator progress format. \"Page x of n\"")
        let formattedProgress = String.localizedStringWithFormat(format, pageIndex, pageCount)
        return formattedProgress
    }

    static let zero = CarouselGridPagingProgress(pageIndex: 0, pageCount: 0)
}

class CarouselGridCollectionViewController: UICollectionViewController {

    var progressPublisher: PublishedValue<CarouselGridPagingProgress>.Publisher {
        return layout.$progress
    }

    @objc func scrollToNextPage() {
        if let indexPath = layout.firstIndexPathForPageWithOffsetFromCurrentPage(offset: 1) {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }

    @objc func scrollToPreviousPage() {
        if let indexPath = layout.firstIndexPathForPageWithOffsetFromCurrentPage(offset: -1) {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }

    var layout: CarouselGridLayout {
        return self.collectionViewLayout as! CarouselGridLayout
    }

    init() {
        let layout = CarouselGridLayout()
        layout.numberOfColumns = 2
        layout.numberOfRows = .fixedCount(3)
        layout.interItemSpacing = 24
        super.init(collectionViewLayout: layout)
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.setCollectionViewLayout(self.layout, animated: false)
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        collectionView.allowsMultipleSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollToMiddleSection()
    }

    func scrollToMiddleSection() {
        let sectionCount = collectionView.numberOfSections
        collectionView.scrollToItem(at: IndexPath(item: 0, section: sectionCount / 2),
                                    at: .left,
                                    animated: false)
    }
}
