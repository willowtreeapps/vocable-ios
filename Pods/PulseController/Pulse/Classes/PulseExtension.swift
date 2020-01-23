//
//  PulseExtension.swift
//  Pulse
//
//  Created by Dawid Cieslak on 14/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

extension Pulse {
    
    public convenience init( measureClosure: @escaping (() -> CGFloat), outputClosure: @escaping ((_ output: CGFloat) -> Void)) {
        let configuration = Pulse.Configuration(minimumValueStep: 0.005, Kp: 1.0, Ki: 0.1, Kd: 0.1)
        self.init(configuration: configuration, measureClosure: measureClosure, outputClosure: outputClosure)
    }
    
    public func showTunningView(minimumValue: CGFloat, maximumValue: CGFloat) {
        tunningWindow = TunningWindow(frame: UIScreen.main.bounds)
        tunningWindow?.windowLevel = UIWindowLevelAlert + 1
        tunningWindow?.translatesAutoresizingMaskIntoConstraints = false

        guard let alertWindow = tunningWindow else {
            return
        }
        
        let proxyOutputClosure = self.outputClosure

        // Create `TunningView`
        let tunningViewConfiguration: TunningView.Configuration = TunningView.Configuration(minimumValue: minimumValue, maximumValue: maximumValue, initialConfiguration: configuration)
        let tunningViewController: TunningViewController = TunningViewController(configuration: tunningViewConfiguration, closeClosure: {  (sender) in
            alertWindow.rootViewController = nil
            alertWindow.isHidden = true
            self.outputClosure = proxyOutputClosure
            self.setPointChangedClosure = nil
        }, configurationChanged: { [weak self] (sender, newConfiguration) in
            guard let `self` = self else { return }
            self.configuration = newConfiguration
        })
    
        // Listen to changes in `output` and new `setPoint`
        self.outputClosure = { newValue in
            tunningViewController.pulseOutputValue = newValue
            proxyOutputClosure(newValue)
        }
   
        self.setPointChangedClosure = { newValue in
            tunningViewController.setPointValue = newValue
        }
        
        alertWindow.rootViewController = tunningViewController
        alertWindow.makeKeyAndVisible()
        alertWindow.isHidden = false
        
        // Show `TunningView`
        tunningViewController.show()
    }
}
