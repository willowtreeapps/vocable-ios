//
//  TrackingContainerViewController.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

final class TrackingContainerViewController: UIViewController {

    @IBOutlet private var cursorView: UIVirtualCursorView!

    private var contentViewController: UIViewController!
    private var trackingViewController: UIHeadGazeViewController?

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        AppConfig.$isHeadTrackingEnabled.sink { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.installTrackingViewController()
            } else {
                self.removeTrackingViewController()
            }
        }.store(in: &cancellables)
    }

    private func installTrackingViewController() {
        guard trackingViewController?.parent == nil else { return }

        let trackingViewController = UIHeadGazeViewController()
        let trackingView = trackingViewController.view!
        trackingView.isHidden = true
        addChild(trackingViewController)

        trackingView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(trackingView, at: 0)
        trackingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        trackingView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        trackingView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        trackingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        trackingViewController.didMove(toParent: self)
        self.trackingViewController = trackingViewController
    }

    private func removeTrackingViewController() {
        guard let trackingViewController = trackingViewController else { return }
        trackingViewController.willMove(toParent: nil)
        trackingViewController.removeFromParent()
        trackingViewController.view.removeFromSuperview()
        self.trackingViewController = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContentViewControllerSegue" {
            self.contentViewController = segue.destination
        }
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }
}
