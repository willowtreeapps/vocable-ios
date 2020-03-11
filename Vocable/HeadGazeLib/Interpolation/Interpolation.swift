//
//  Interpolation.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 1/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

/// Describes a type that can be interpolated with an Interpolator
///
/// Interpolable types provide a means of expressing their values
/// in a consistent, repeatable order. Interpolable types can also
/// be instantiated via an ordered list of values.
protocol Interpolable {
    var interpolableValues: [Double] { get }
    init(interpolableValues: [Double])
}

/// Describes an entity that integrates a new value with the current value
/// to produce a new "current" value.
///
/// Linear interpolation is a method of curve fitting using linear polynomials
/// to construct new data points within the range of a discrete set of known
/// data points. For our circumstances we tend to use them for smoothing
/// values across time.
protocol Interpolator {

    // The kind of value interpolator that will be used
    // to interpolate. We need a 1:1 mapping between
    // each value of the interpolable type
    // (e.g. CGPoint.x and CGPoint.y) so that they can
    // be interpolated individually and recombined to create
    // a new wholly interpolated instance when needed (a fresh CGPoint)
    associatedtype InterpolatorKind: ValueInterpolator
    var valueInterpolators: [InterpolatorKind] { get }

    associatedtype Element: Interpolable
    var value: Element { get }
    func update(with newValue: Element) -> Element
}

extension Interpolator {

    // Default implementation for interpolation for a given
    // Interpolator. Most implementations will not need to
    // provider their own version of this function unless
    // they need more parameters in their signature.
    func update(with newValue: Element) -> Element {
        let interpolated = zip(newValue.interpolableValues, valueInterpolators).map { (newValue, interpolator) in
            return interpolator.update(with: newValue)
        }
        return Element(interpolableValues: interpolated)
    }
}

/// Describes an entity that performs the actual interpolation between
/// values. These are typically owned by the relevant Interpolator type
/// and are effectively an implementation detail to consumers of the Interpolator.
protocol ValueInterpolator {
    var value: Double { get }
    func update(with newValue: Double) -> Double
}
