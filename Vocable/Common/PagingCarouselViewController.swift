//
//  PagingCarouselViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

@IBDesignable class PagingCarouselViewController: VocableViewController, UICollectionViewDelegate {

    private(set) var paginationView = PaginationView()
    private(set) var collectionView = CarouselGridCollectionView()

    private var disposables = Set<AnyCancellable>()
    private var volatileConstraints = [NSLayoutConstraint]()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    private func commonInit() {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        paginationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paginationView)

        collectionView.progressPublisher.sink(receiveValue: { (pagingProgress) in
            self.paginationView.setPaginationButtonsEnabled(pagingProgress.pageCount > 1)
            self.paginationView.textLabel.text = pagingProgress.localizedString
        }).store(in: &disposables)

        paginationView.nextPageButton.addTarget(collectionView, action: #selector(CarouselGridCollectionView.scrollToNextPage), for: .primaryActionTriggered)

        paginationView.previousPageButton.addTarget(collectionView, action: #selector(CarouselGridCollectionView.scrollToPreviousPage), for: .primaryActionTriggered)

        updateMarginsForSubviews()
        view.setNeedsUpdateConstraints()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        updateMarginsForSubviews()
    }

    private func updateMarginsForSubviews() {
        let margins = view.layoutMargins
        if sizeClass.contains(any: .compact) {
            collectionView.layout.pageInsets = .init(top: 8, left: margins.left, bottom: 24, right: margins.right)
        } else {
            collectionView.layout.pageInsets = .init(top: 16, left: margins.left, bottom: 32, right: margins.right)
        }
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        NSLayoutConstraint.deactivate(volatileConstraints)

        var constraints = [NSLayoutConstraint]()

        let layoutMargins = view.layoutMarginsGuide

        if let navigationBar = navigationBarIfLoaded() {

            // CollectionView top + Navigation bar boundary
            constraints += [
                collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor)
            ]

        } else {

            // CollectionView top boundary
            constraints += [
                collectionView.topAnchor.constraint(equalTo: layoutMargins.topAnchor)
            ]
        }

        // Collection view
        constraints += [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        // Pagination view
        constraints += [
            paginationView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            paginationView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMargins.leadingAnchor),
            paginationView.trailingAnchor.constraint(lessThanOrEqualTo: layoutMargins.trailingAnchor),
            paginationView.bottomAnchor.constraint(greaterThanOrEqualTo: layoutMargins.bottomAnchor),
            paginationView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }
}
