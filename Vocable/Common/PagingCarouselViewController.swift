//
//  PagingCarouselViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

@IBDesignable class PagingCarouselViewController: UIViewController, UICollectionViewDelegate {

    private var _navigationBar: VocableNavigationBar?
    private(set) lazy var navigationBar: VocableNavigationBar = self.installNavigationBar()
    private(set) var paginationView = PaginationView()
    private(set) var collectionView = CarouselGridCollectionView()

    private var disposables = Set<AnyCancellable>()
    private var volatileConstraints = [NSLayoutConstraint]()

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .collectionViewBackgroundColor

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
        updateViewForCurrentTraitCollection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        installBackButtonIfNeeded()
    }

    private func installBackButtonIfNeeded() {

        guard navigationBar.leftButton == nil else { return }
        guard let navigationController = navigationController else {
            return
        }
        let viewControllers = navigationController.viewControllers
        guard viewControllers.contains(self) else {
            return
        }
        guard viewControllers.first != self else {
            return
        }

        navigationBar.leftButton = {
            let button = VocableNavigationBarButton(frame: .zero)
            button.buttonImage = UIImage(systemName: "arrow.left")
            button.addTarget(navigationController,
                             action: #selector(UINavigationController.popViewController(animated:)),
                             for: .primaryActionTriggered)
            return button
        }()
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
        _navigationBar?.preservesSuperviewLayoutMargins = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewForCurrentTraitCollection()
    }

    private func installNavigationBar() -> VocableNavigationBar {
        let bar = VocableNavigationBar(frame: .zero)
        bar.setContentHuggingPriority(.required, for: .vertical)
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        _navigationBar = bar
        updateViewForCurrentTraitCollection()
        return bar
    }

    private func updateViewForCurrentTraitCollection() {

        if sizeClass.contains(any: .compact) {
            view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            view.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        }

        NSLayoutConstraint.deactivate(volatileConstraints)

        var constraints = [NSLayoutConstraint]()

        let layoutMargins = view.layoutMarginsGuide

        if let navigationBar = _navigationBar {

            // Navigation bar
            constraints += [
                navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]

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
