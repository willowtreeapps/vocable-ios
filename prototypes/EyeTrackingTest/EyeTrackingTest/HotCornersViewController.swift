//
//  HotCornersViewController.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/22/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class HotCornersViewController: UIViewController {
    
    let trackingEngine = TrackingEngine()
    
    let trackingView: UIView = UIView()
    lazy var screenTrackingViewController: ScreenTrackingViewController = {
        let vc = ScreenTrackingViewController()
        vc.delegate = self
        return vc
    }()
    
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
    
    func configureUI() {
        guard self.isViewLoaded else { return }
        
        self.screenTrackingViewController.showDebug = self.showDebug
        self.screenTrackingViewController.trackingConfiguration = self.trackingConfiguration
    }
    
    lazy var upperLeftHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var upperRightHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerLeftHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerRightHotCorner: HotCornerView = {
        let view = HotCornerView()
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 48.0, height: 48.0))
        view.alpha = 0.0
        return view
    }()
    
    lazy var hotCornerGroup: TrackingGroup = TrackingGroup(widgets: [
        self.upperLeftHotCorner,
        self.upperRightHotCorner,
        self.lowerLeftHotCorner,
        self.lowerRightHotCorner]
    )
    
    lazy var sixButtonKeyboardViewController: SixButtonKeyboardViewController = {
        let controller = SixButtonKeyboardViewController.get(from: .sixButtonKeyboardViewController)
        return controller
    }()
    
    lazy var presetsViewController: PresetsViewController = {
        let controller = PresetsViewController.get(from: .presets)
        return controller
    }()
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBackgroundColor
        
        self.screenTrackingViewController.add(to: self, in: nil)
        
        trackingView.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        trackingView.layer.cornerRadius = 20.0
        trackingView.backgroundColor = UIColor.purple.withAlphaComponent(0.8)
        
        self.hotCornerGroup.add(to: self.trackingEngine)
        
        self.view.addSubview(trackingView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 0.0
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            self.configureHotCornerCenters()
            hotCorners.forEach { view in
                view.alpha = 1.0
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let hotCorners = [self.upperLeftHotCorner, self.upperRightHotCorner, self.lowerLeftHotCorner, self.lowerRightHotCorner]
        hotCorners.forEach { view in
            view.alpha = 1.0
        }
        self.trackingEngine.enable()
        self.configureHotCornerCenters()
        self.screenTrackingViewController.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.trackingEngine.disable()
        self.screenTrackingViewController.delegate = nil
    }
    
    func configureHotCornerCenters() {
        self.upperLeftHotCorner.center = CGPoint(x: 0.0, y: 0.0)
        self.upperRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: 0.0)
        self.lowerLeftHotCorner.center = CGPoint(x: 0.0, y: self.view.bounds.maxY)
        self.lowerRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.maxY)
    }
    
    func configureOnGazes() {
        self.upperLeftHotCorner.onGaze = { _ in
            print("Upper Left")
        }
        
        self.upperRightHotCorner.onGaze = { _ in
            print("Upper Right")
        }
        
        self.lowerLeftHotCorner.onGaze = { _ in
            print("Lower Left")
        }
        
        self.lowerRightHotCorner.onGaze = { _ in
            print("Lower Right")
        }
    }
}

extension HotCornersViewController: ScreenTrackingViewControllerDelegate {
    func didUpdateTrackedPosition(_ trackedPositionOnScreen: CGPoint?, for screenTrackingViewController: ScreenTrackingViewController) {
        DispatchQueue.main.async {
            if let position = trackedPositionOnScreen {
                self.trackingView.isHidden = false
                let positionInView = self.view.convert(position, from: nil)
                self.trackingView.center = positionInView
                self.trackingEngine.updateWithTrackedPoint(position)
            } else {
                self.trackingView.isHidden = true
            }
        }
    }
}
