//
//  VocableViewController.swift
//  Vocable
//
//  Created by Chris Stroud on 4/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable class VocableViewController: UIViewController {
    
    private var _navigationBar: VocableNavigationBar?
    var navigationBar: VocableNavigationBar {
        return _navigationBar ?? self.installNavigationBar()
    }

    func navigationBarIfLoaded() -> VocableNavigationBar? {
        return _navigationBar
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
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .collectionViewBackgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewMarginsForCurrentTraitCollection()
        installBackButtonIfNeeded()
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setViewMarginsForCurrentTraitCollection()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setViewMarginsForCurrentTraitCollection()
        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func setViewMarginsForCurrentTraitCollection() {
        let proposedMargins: UIEdgeInsets
        if sizeClass.contains(any: .compact) {
            proposedMargins = UIEdgeInsets(top: 8, left: 8, bottom: 24, right: 8)
        } else {
            proposedMargins = UIEdgeInsets(top: 24, left: 24, bottom: 32, right: 24)
        }
        var newMargins = view.layoutMargins

        if edgesForExtendedLayout.contains(.top) {
            newMargins.top = proposedMargins.top
        }
        if edgesForExtendedLayout.contains(.left) {
            newMargins.left = proposedMargins.left
        }
        if edgesForExtendedLayout.contains(.right) {
            newMargins.right = proposedMargins.right
        }
        if edgesForExtendedLayout.contains(.bottom) {
            newMargins.bottom = proposedMargins.bottom
        }

        if view.layoutMargins != newMargins {
            view.layoutMargins = newMargins
        }
    }

    private func installBackButtonIfNeeded() {

        guard let navigationBar = navigationBarIfLoaded(), navigationBar.leftButton == nil, let navigationController = navigationController else {
            return
        }
        let viewControllers = navigationController.viewControllers
        guard viewControllers.contains(self), viewControllers.first != self else {
            return
        }

        navigationBar.leftButton = {
            let button = GazeableButton(frame: .zero)
            button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            button.accessibilityID = .shared.backButton
            button.addTarget(navigationController,
                             action: #selector(UINavigationController.popViewController(animated:)),
                             for: .primaryActionTriggered)
            return button
        }()
    }

    private func installNavigationBar() -> VocableNavigationBar {

        let bar = VocableNavigationBar(frame: .zero)
        bar.setContentHuggingPriority(.required, for: .vertical)
        bar.preservesSuperviewLayoutMargins = true
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        _navigationBar = bar
        view.setNeedsUpdateConstraints()
        return bar
    }
}
