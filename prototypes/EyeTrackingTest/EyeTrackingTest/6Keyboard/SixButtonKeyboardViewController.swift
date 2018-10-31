//
//  6KeyboardViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 10/24/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

class SixButtonKeyboardViewController: UIViewController, ScreenTrackingViewControllerDelegate {

    @IBOutlet var topLeftKey: UIView!
    @IBOutlet var bottomLeftKey: UIView!
    @IBOutlet var topCenterKey: UIView!
    @IBOutlet var bottomCenterKey: UIView!
    @IBOutlet var topRightKey: UIView!
    @IBOutlet var bottomRightKey: UIView!


    // MARK: - View Lifecycle

    let trackingView: UIView = UIView()
    lazy var screenTrackingViewController: ScreenTrackingViewController = {
        let vc = ScreenTrackingViewController()
        vc.delegate = self
        return vc
    }()

    func configureUI() {
        guard self.isViewLoaded else { return }

        self.screenTrackingViewController.showDebug = self.showDebug
        self.screenTrackingViewController.trackingConfiguration = self.trackingConfiguration
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.screenTrackingViewController.willMove(toParent: self)
        self.screenTrackingViewController.view.frame = self.view.bounds
        self.screenTrackingViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.view.addSubview(self.screenTrackingViewController.view)
        self.addChild(self.screenTrackingViewController)
        self.screenTrackingViewController.didMove(toParent: self)

        self.screenTrackingViewController.view.alpha = 0.3

//        self.view.bringSubviewToFront(self.buttonStackView)

        trackingView.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        trackingView.layer.cornerRadius = 20.0
        trackingView.backgroundColor = UIColor.purple.withAlphaComponent(0.8)
        self.view.addSubview(trackingView)

        self.configureUI()
    }


    // MARK: - ScreenTrackingViewControllerDelegate

    func didUpdateTrackedPosition(_ trackedPositionOnScreen: CGPoint?, for screenTrackingViewController: ScreenTrackingViewController) {
        DispatchQueue.main.async {
            if let position = trackedPositionOnScreen {
                self.trackingView.isHidden = false
                self.trackingView.center = position
            } else {
                self.trackingView.isHidden = true
            }
        }
    }

    var showDebug: Bool = true {
        didSet {
            self.configureUI()
        }
    }

    var trackingConfiguration: TrackingConfiguration = .headTracking {
        didSet {
            self.configureUI()
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.showDebug = !self.showDebug
        }
    }

}
