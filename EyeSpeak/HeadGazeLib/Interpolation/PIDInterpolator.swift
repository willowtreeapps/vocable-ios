//
//  PIDInterpolator.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import CoreGraphics

class PIDInterpolator<E: Interpolable>: Interpolator {

    let valueInterpolators: [InterpolatorKind]
    var value: E {
        return E(interpolableValues: valueInterpolators.map {$0.value})
    }

    var pulse: Pulse {
        return valueInterpolators.first!.pidController
    }

    var needsResetOnNextUpdate = false {
        didSet {
            for interpolator in valueInterpolators {
                interpolator.needsResetOnNextUpdate = true
            }
        }
    }

    let config: Pulse.Configuration

    init(initialValue: E) {
        let config = Pulse.Configuration(minimumValueStep: 0.010, Kp: 3.307, Ki: 0.365, Kd: 0.690)
        self.valueInterpolators = initialValue.interpolableValues.map {
            return InterpolatorKind(configuration: config, initialValue: $0)
        }
        self.config = config
    }

    func update(with newValue: E) -> E {
        let interpolated = zip(newValue.interpolableValues, valueInterpolators).map { (newValue, interpolator) in
            return interpolator.update(with: newValue)
        }
        return E(interpolableValues: interpolated)
    }

    class InterpolatorKind: ValueInterpolator {
        private(set) var value: Double
        fileprivate var needsResetOnNextUpdate = false
        fileprivate let configuration: Pulse.Configuration
        fileprivate lazy var pidController: Pulse = {
            return Pulse(configuration: self.configuration, measureClosure: { () -> CGFloat in
                return CGFloat(self.value)
            }, outputClosure: { (output) in
                self.value = Double(output)
            })
        }()

        init(configuration: Pulse.Configuration, initialValue: Double) {
            self.configuration = configuration
            self.value = initialValue
            pidController.setPoint = CGFloat(initialValue)
        }

        func update(with newValue: Double) -> Double {
            pidController.setPoint = CGFloat(newValue)
            return value
        }
    }
}
