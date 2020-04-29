//
//  PagingCarouselViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable class PagingCarouselViewController: UIViewController, UICollectionViewDelegate {

    var showsAutomaticBackButton: Bool = true

    private var _navigationBar: VocableNavigationBar?
    private(set) lazy var navigationBar: VocableNavigationBar = self.installNavigationBar()
    private(set) var paginationView = PaginationView()
    private(set) var collectionView = CarouselGridCollectionView()

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

        updateViewForCurrentTraitCollection()

        demoStuff()
    }

    #warning("WITNESS ME")
    private func demoStuff() {
        navigationBar.title = "Witness me"
        navigationBar.rightButton = {
            let button = GazeableButton(frame: .zero)
            button.buttonImage = #imageLiteral(resourceName: "Speak")
            return button
        }()

        navigationBar.leftButton = {
            let button = GazeableButton(frame: .zero)
            button.buttonImage = UIImage(systemName: "xmark.circle")?.applyingSymbolConfiguration(.init(pointSize: 22, weight: .bold))
            return button
        }()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        // Update the paging insets on the grid layout
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewForCurrentTraitCollection()
    }

    private func installNavigationBar() -> VocableNavigationBar {
        let bar = VocableNavigationBar(frame: .zero)
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        _navigationBar = bar
        updateViewForCurrentTraitCollection()
        return bar
    }

    func updateViewForCurrentTraitCollection() {

        let sizeClass = (horizontal: traitCollection.horizontalSizeClass,
                         vertical: traitCollection.verticalSizeClass)

        if sizeClass.vertical == .compact {
            view.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 8, right: 24)
        } else {
            view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
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
            paginationView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
            paginationView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMargins.leadingAnchor),
            paginationView.trailingAnchor.constraint(lessThanOrEqualTo: layoutMargins.trailingAnchor),
            paginationView.bottomAnchor.constraint(greaterThanOrEqualTo: layoutMargins.bottomAnchor),
            paginationView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }
}
