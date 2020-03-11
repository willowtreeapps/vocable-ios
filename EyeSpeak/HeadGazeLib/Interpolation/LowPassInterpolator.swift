//
//  LowPassInterpolator.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 1/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

/// A low-pass filter interpolator.
///
/// Values given to the interpolator are weighted and summed with
/// the inversely-weighted current value of the interpolator. The weight is
/// derived by the filterFactor. If the filterFactor is set to 0.5, the interpolator
/// would effectively be averaging the previous value and the new value to
/// compute its newly updated state.
class LowPassInterpolator<E: Interpolable>: Interpolator {
    let filterFactor: Double
    let valueInterpolators: [InterpolatorKind]
    var value: E {
        return E(interpolableValues: valueInterpolators.map {$0.value})
    }

    var needsResetOnNextUpdate = false {
        didSet {
            for interpolator in valueInterpolators {
                interpolator.needsResetOnNextUpdate = true
            }
        }
    }

    init(filterFactor: Double, initialValue: E) {
        self.filterFactor = filterFactor
        self.valueInterpolators = initialValue.interpolableValues.map {
            return InterpolatorKind(filterFactor: filterFactor, initialValue: $0)
        }
    }

    func update(with newValue: E, factor: Double?) -> E {
        let interpolated = zip(newValue.interpolableValues, valueInterpolators).map { (newValue, interpolator) in
            return interpolator.update(with: newValue, factor: factor)
        }
        return E(interpolableValues: interpolated)
    }

    class InterpolatorKind: ValueInterpolator {
        let filterFactor: Double
        fileprivate var needsResetOnNextUpdate = false
        init(filterFactor: Double, initialValue: Double) {
            self.filterFactor = filterFactor
            self.value = initialValue
        }

        private(set) var value: Double
        func update(with newValue: Double) -> Double {
            return self.update(with: newValue, factor: nil)
        }

        func update(with newValue: Double, factor: Double?) -> Double {
            if needsResetOnNextUpdate {
                value = newValue
                needsResetOnNextUpdate = false
                return value
            }
            let f = factor ?? filterFactor
            value = f * newValue + (1.0 - f) * value
            return value
        }
    }
}
