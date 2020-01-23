//
//  HotCornersTrackableViewController.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/22/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit
import PulseController

class HotCornersTrackableViewController: UIViewController {
    struct Constants {
        static let hotCornerSize = CGSize(width: 48, height: 48)
        static let trackingViewSize = CGSize(width: 60, height: 60)
        static let initialHotCornerBounds = CGRect(origin: CGPoint(x: -24, y: -24), size: Constants.hotCornerSize)
    }
    
    var isUnlocked = true {
        didSet {
            self.currentTrackingEngine?.isUnlocked = self.isUnlocked
        }
    }
    
    let parentTrackingEngine = TrackingEngine()
    var currentTrackingEngine: TrackingEngine? {
        didSet {
            self.currentTrackingEngine?.parent = self.parentTrackingEngine
            self.currentTrackingEngine?.isUnlocked = self.isUnlocked
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
    
    func configureUI() {
        guard self.isViewLoaded else { return }
        
        self.screenTrackingViewController.showDebug = self.showDebug
        self.screenTrackingViewController.trackingConfiguration = self.trackingConfiguration
    }
    
    lazy var upperLeftHotCorner: HotCornerView = {
        let view = HotCornerView(location: .upperLeft)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var upperRightHotCorner: HotCornerView = {
        let view = HotCornerView(location: .upperRight)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerLeftHotCorner: HotCornerView = {
        let view = HotCornerView(location: .lowerLeft)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
        view.alpha = 0.0
        return view
    }()
    
    lazy var lowerRightHotCorner: HotCornerView = {
        let view = HotCornerView(location: .lowerRight)
        self.view.addSubview(view)
        view.frame = CGRect(origin: .zero, size: Constants.hotCornerSize)
        view.bounds = Constants.initialHotCornerBounds
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
        var component = HotCornerGazeableComponent()
        component.onUpperLeftGaze = { _ in
            self.showPresetsViewController()
        }
        component.upperLeftTitle = "Presets"
        component.lowerLeftTitle = "Pause"
        component.onLowerLeftGaze = { _ in
            self.isUnlocked.toggle()
        }
        let controller = SixButtonKeyboardViewController.get(fromStoryboard: .sixButtonKeyboardViewController, component: component)
        controller.add(to: self)
        return controller
    }()
    
    lazy var presetsViewController: PresetsViewController = {
        var component = HotCornerGazeableComponent()
        component.onUpperLeftGaze = { _ in
            self.showSixButtonKeyboardViewController()
        }
        component.upperLeftTitle = "Back"
        component.lowerLeftTitle = "Pause"
        component.onLowerLeftGaze = { _ in
            self.isUnlocked.toggle()
        }
        let controller = PresetsViewController.get(fromStoryboard: .presets, component: component)
        controller.add(to: self)
        return controller
    }()
    
    let trackingView = CursorView()
    lazy var screenTrackingViewController: ScreenTrackingViewController = {
        let vc = ScreenTrackingViewController()
        vc.add(to: self)
        vc.delegate = self
        return vc
    }()
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBackgroundColor
        
        self.screenTrackingViewController.show(in: self.view)
        
        trackingView.frame = CGRect(origin: .zero, size: Constants.trackingViewSize)
        
        self.hotCornerGroup.add(to: self.parentTrackingEngine)
        self.view.addSubview(trackingView)
        
        self.sixButtonKeyboardViewController.show(in: self.containerView)
        self.configure(with: self.sixButtonKeyboardViewController)
        
        self.trackingView.center = self.view.center

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        recognizer.numberOfTouchesRequired = 1
        UIApplication.shared.keyWindow?.addGestureRecognizer(recognizer)
    }

    @objc func onTap() {
        self.xPulse.showTunningView(minimumValue: 0, maximumValue: self.view.bounds.width)
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
        self.configureHotCornerCenters()
        self.screenTrackingViewController.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.screenTrackingViewController.delegate = nil
    }
    
    func configureHotCornerCenters() {
        self.upperLeftHotCorner.center = CGPoint(x: 0.0, y: 0.0)
        self.upperRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: 0.0)
        self.lowerLeftHotCorner.center = CGPoint(x: 0.0, y: self.view.bounds.maxY)
        self.lowerRightHotCorner.center = CGPoint(x: self.view.bounds.maxX, y: self.view.bounds.maxY)
    }
    
    func configure(with trackable: HotCornerTrackable) {
        self.currentTrackingEngine = trackable.trackingEngine
        self.upperLeftHotCorner.onGaze = trackable.component?.onUpperLeftGaze
        self.upperRightHotCorner.onGaze = trackable.component?.onUpperRightGaze
        self.lowerLeftHotCorner.onGaze = trackable.component?.onLowerLeftGaze
        self.lowerRightHotCorner.onGaze = trackable.component?.onLowerRightGaze
        self.upperLeftHotCorner.text = trackable.component?.upperLeftTitle
        self.upperRightHotCorner.text = trackable.component?.upperRightTitle
        self.lowerLeftHotCorner.text = trackable.component?.lowerLeftTitle
        self.lowerRightHotCorner.text = trackable.component?.lowerRightTitle
    }
    
    func showSixButtonKeyboardViewController() {
        self.presetsViewController.hideFromParentViewController()
        self.sixButtonKeyboardViewController.show(in: self.containerView)
        self.configure(with: self.sixButtonKeyboardViewController)
    }
    
    func showPresetsViewController() {
        self.sixButtonKeyboardViewController.hideFromParentViewController()
        self.presetsViewController.show(in: self.containerView)
        self.configure(with: self.presetsViewController)
    }

    lazy var pulseConfig = Pulse.Configuration(minimumValueStep: 0.05, Kp: 2.511, Ki: 0.1, Kd: 0.7)
    var cursorPoint: CGPoint = .zero {
        didSet {
            if DispatchQueue.isMainQueue {
                updateCursorPosition(self.cursorPoint)
            } else {
                DispatchQueue.main.async {
                    self.updateCursorPosition(self.cursorPoint)
                }
            }
        }
    }

    lazy var xPulse = Pulse(configuration: self.pulseConfig, measureClosure: { () -> CGFloat in
        return self.cursorPoint.x
    }, outputClosure: { output in
        self.cursorPoint.x = output
//        self.cursorPoint.y = self.view.bounds.height / 2
    })

    lazy var yPulse = Pulse(configuration: self.pulseConfig, measureClosure: { () -> CGFloat in
        return self.cursorPoint.y
    }, outputClosure: { output in
        self.cursorPoint.y = output
    })


    func updateCursorPosition(_ point: CGPoint) {
        self.trackingView.isHidden = false
        let positionInView = self.view.convert(point, from: nil)
        self.trackingView.center = positionInView
        if let engine = self.currentTrackingEngine {
            _ = engine.updateWithTrackedPoint(point)
        } else {
            _ = self.parentTrackingEngine.updateWithTrackedPoint(point)
        }
    }
}

extension HotCornersTrackableViewController: ScreenTrackingViewControllerDelegate {
    func didGestureForCalibration() {
        // do stuff here
        self.currentTrackingEngine?.isUnlocked = false
        self.parentTrackingEngine.isUnlocked = false
    }
    
    func didFinishCalibrationGesture() {
        self.currentTrackingEngine?.isUnlocked = self.isUnlocked
        self.parentTrackingEngine.isUnlocked = true
    }
    
    func didUpdateTrackedPosition(_ trackedPositionOnScreen: CGPoint?, for screenTrackingViewController: ScreenTrackingViewController) {
        if let position = trackedPositionOnScreen {
            xPulse.setPoint = position.x
            yPulse.setPoint = position.y
        }
    }
}
