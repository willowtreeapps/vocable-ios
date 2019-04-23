//
//  ViewController.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 6/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ScreenTrackingViewControllerDelegate {

    var showDebug: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.configureUI()
            }
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


    // MARK: - Demo Interface

    @IBOutlet var buttonStackView: UIStackView!
    @IBOutlet var buttons: [UIButton]!
    var animatorsForButtons: [UIButton: UIViewPropertyAnimator] = [:]

    func updateButtonHighlightForTrackingPosition() {

        for button in self.buttons {
            if button.hitTest(self.view.convert(self.trackingView.center, to: button), with: nil) != nil {
                button.isHighlighted = true

                let animator: UIViewPropertyAnimator
                if let a = animatorsForButtons[button] {
                    animator = a
                } else {
                    let springParams = UISpringTimingParameters(dampingRatio: 1.0)
                    animator = UIViewPropertyAnimator(duration: 0.0, timingParameters: springParams)
                    animatorsForButtons[button] = animator
                }

                animator.stopAnimation(true)
                animator.addAnimations {
                    button.transform = CGAffineTransform(scaleX: 0.87, y: 0.87)
                }
                animator.startAnimation()

            } else {
                button.isHighlighted = false

                if let animator = animatorsForButtons[button] {
                    animator.stopAnimation(true)
                    animator.addAnimations {
                        button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }
                    animator.startAnimation()
                }
            }
        }
    }

    func configureUI() {
        guard self.isViewLoaded else { return }

        self.buttonStackView.isHidden = self.showDebug
        self.screenTrackingViewController.showDebug = self.showDebug
        self.screenTrackingViewController.trackingConfiguration = self.trackingConfiguration
    }


    // MARK: - View Lifecycle

    let trackingView: UIView = UIView()
    lazy var screenTrackingViewController: ScreenTrackingViewController = {
        let vc = ScreenTrackingViewController()
        vc.delegate = self
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.screenTrackingViewController.willMove(toParent: self)
        self.screenTrackingViewController.view.frame = self.view.bounds
        self.screenTrackingViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.view.addSubview(self.screenTrackingViewController.view)
        self.addChild(self.screenTrackingViewController)
        self.screenTrackingViewController.didMove(toParent: self)

        self.view.bringSubviewToFront(self.buttonStackView)

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
                self.updateButtonHighlightForTrackingPosition()
            } else {
                self.trackingView.isHidden = true
            }
        }
    }

}
