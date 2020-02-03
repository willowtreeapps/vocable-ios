//
//  LowPassInterpolator.swift
//  demo
//
//  Created by Chris Stroud on 1/31/20.
//  Copyright © 2020 Xie,Jinrong. All rights reserved.
//

import Foundation

class LowPassInterpolator<E: Interpolable>: Interpolator {
    let filterFactor: Double
    let valueInterpolators: [InterpolatorKind]
    var value: E {
        return E(interpolableValues: valueInterpolators.map{$0.value})
    }
    init(filterFactor: Double, initialValue: E) {
        self.filterFactor = filterFactor
        self.valueInterpolators = initialValue.interpolableValues.map {
            return InterpolatorKind(filterFactor: filterFactor, initialValue: $0)
        }
    }

    func update(with newValue: E, factor: Double?) -> E {
        if let factor = factor, abs(factor - filterFactor) > 0.1 {
            print("factor: \(factor)")
        }
        let interpolated = zip(newValue.interpolableValues, valueInterpolators).map { (newValue, interpolator) in
            return interpolator.update(with: newValue, factor: factor)
        }
        return E(interpolableValues: interpolated)
    }

    class InterpolatorKind: ValueInterpolator {
        let filterFactor: Double
        init(filterFactor: Double, initialValue: Double) {
            self.filterFactor = filterFactor
            self.value = initialValue
        }

        private(set) var value: Double
        func update(with newValue: Double) -> Double {
            return self.update(with: newValue, factor: nil)
        }

        func update(with newValue: Double, factor: Double?) -> Double {
            let f = factor ?? filterFactor
            value = f * newValue + (1.0 - f) * value
            return value
        }
    }
}
