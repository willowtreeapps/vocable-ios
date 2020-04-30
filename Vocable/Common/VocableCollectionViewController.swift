//
//  VocableCollectionViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class VocableCollectionViewController: VocableViewController, UICollectionViewDelegate {

    private(set) var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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

        view.backgroundColor = .collectionViewBackgroundColor

        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
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
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        volatileConstraints = constraints
    }
}
