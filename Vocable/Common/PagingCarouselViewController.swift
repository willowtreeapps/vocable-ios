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

    typealias CollectionViewType = CarouselGridCollectionView

    private(set) var paginationView = PaginationView()
    private(set) var collectionView = CollectionViewType()

    private var disposables = Set<AnyCancellable>()
    private var volatileConstraints = [NSLayoutConstraint]()

    var isPaginationViewHidden = false {
        didSet {
            guard oldValue != isPaginationViewHidden else { return }
            if isPaginationViewHidden {
                paginationView.removeFromSuperview()
            } else {
                view.addSubview(paginationView)
            }
            view.setNeedsUpdateConstraints()
        }
    }

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
        collectionView.preservesSuperviewLayoutMargins = true
        view.addSubview(collectionView)

        paginationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paginationView)

        collectionView.progressPublisher.sink(receiveValue: { [weak self] (pagingProgress) in
            guard let self = self else { return }
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
        var insets = view.layoutMargins

        // The navigation bar will inherit this inset
        // and we'll specify our desired inset from the
        // navigation bar separately
        if navigationBarIfLoaded() != nil {
            insets.top = 8
        }

        insets.bottom = 8
        if isPaginationViewHidden {
            insets.bottom += view.safeAreaInsets.bottom
        }
        
        collectionView.layout.pageInsets = insets
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
        if isPaginationViewHidden {
            constraints += [
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        } else {
            constraints += [
                paginationView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
                paginationView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMargins.leadingAnchor),
                paginationView.trailingAnchor.constraint(lessThanOrEqualTo: layoutMargins.trailingAnchor),
                paginationView.bottomAnchor.constraint(greaterThanOrEqualTo: layoutMargins.bottomAnchor),
                paginationView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        }
        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }
}
