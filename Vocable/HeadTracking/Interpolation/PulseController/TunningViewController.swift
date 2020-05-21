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
    private var tunningView: TunningView?
    weak var pulse: Pulse?

    private let displayLinkProxy: DisplayLinkTargetProxy = DisplayLinkTargetProxy()
    
    // Called when `Tunning View` should be fully removed from screen`
    var closeClosure: ((TunningViewController) -> Void)
    
    // Called when developer changes `PID` configuration
    var configurationChanged: ((TunningViewController, Pulse.Configuration) -> Void)
    
    override func loadView() {
        view = tunningView
    }
    
    init(pulse: Pulse, configuration: TunningView.Configuration, closeClosure: @escaping ((TunningViewController) -> Void), configurationChanged: @escaping ((TunningViewController, Pulse.Configuration) -> Void)) {
        self.closeClosure = closeClosure
        self.configurationChanged = configurationChanged
        self.pulse = pulse

        super.init(nibName: nil, bundle: nil)

        self.tunningView = TunningView(isHorizontal: pulse.isHorizontal, configuration: configuration, closeClosure: { [weak self] _ in
            guard let self = self else { return }
            self.closeClosure(self)
        }, configurationChanged: { [weak self] (_, configuration) in
            guard let self = self else { return }
            self.configurationChanged(self, configuration)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
         tunningView?.layoutIfNeeded()
         tunningView?.visibilityState = .fullyVisible
    }
}
