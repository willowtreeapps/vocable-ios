//
//  TunningViewController.swift
//  Pulse
//
//  Created by Dawid Cieslak on 21/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// Responsible for managing all tuning components
class TunningViewController: UIViewController {
    
    /// Wraps all UI components for tuning
    private var tunningView: TunningView? = nil
    
    /// Tracks change of
    var setPointValue: CGFloat = 0
    var pulseOutputValue: CGFloat = 0
    
    private let displayLink: CADisplayLink
    private let displayLinkProxy: DisplayLinkTargetProxy = DisplayLinkTargetProxy()
    
    // Called when `Tunning View` should be fully removed from screen`
    var closeClosure: ((TunningViewController) -> Void)
    
    // Called when developer changes `PID` configuration
    var configurationChanged: ((TunningViewController, Pulse.Configuration) -> Void)
    
    override func loadView() {
        view = tunningView
    }
    
    init(configuration: TunningView.Configuration, closeClosure: @escaping ((TunningViewController) -> Void), configurationChanged: @escaping ((TunningViewController, Pulse.Configuration) -> Void)) {
        self.closeClosure = closeClosure
        self.configurationChanged = configurationChanged
        self.displayLink = CADisplayLink(target: displayLinkProxy, selector: #selector(tick))
        
        super.init(nibName: nil, bundle: nil)
        
        // Setup timer
        displayLinkProxy.target = self
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        self.tunningView = TunningView(configuration: configuration, closeClosure: { [weak self] (sender) in
            guard let `self` = self else { return }
            self.closeClosure(self)
        }, configurationChanged: { [weak self] (sender, configuration) in
            guard let `self` = self else { return }
            self.configurationChanged(self, configuration)
        })
    }
    
    @objc func tick() {
        tunningView?.drawSetPoint(value: setPointValue)
        tunningView?.drawPulseOutput(value: pulseOutputValue)
        tunningView?.updateGraph()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
         tunningView?.layoutIfNeeded()
         tunningView?.visibilityState = .fullyVisible
    }
    
    deinit {
        displayLink.invalidate()
    }
}

