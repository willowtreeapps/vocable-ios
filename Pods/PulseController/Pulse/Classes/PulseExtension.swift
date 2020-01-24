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
        TunningWindow.shared.tuningContainerViewController.addTuningViewController(for: self, minValue: minimumValue, maxValue: maximumValue)
    }
}
