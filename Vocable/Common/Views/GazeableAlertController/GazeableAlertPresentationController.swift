//
//  GazeableAlertPresentationController.swift
//  Vocable ACC
//
//  Created by Steve Foster on 3/23/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazeableAlertPresentationController: UIPresentationController {

    private lazy var dimmedBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(origin: .zero, size: containerView?.bounds.size ?? .zero)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmedBackgroundView.alpha = 0
        }, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        dimmedBackgroundView.alpha = 0
        containerView?.insertSubview(dimmedBackgroundView, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmedBackgroundView.alpha = 0.6
        }, completion: nil)

    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        guard let containerView = containerView else { return }

        presentedView?.frame = frameOfPresentedViewInContainerView
        dimmedBackgroundView.frame = containerView.bounds
    }

}
