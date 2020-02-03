//
//  Interpolation.swift
//  demo
//
//  Created by Chris Stroud on 1/31/20.
//  Copyright © 2020 Xie,Jinrong. All rights reserved.
//

import Foundation

protocol Interpolable {
    var interpolableValues: [Double] { get }
    init(interpolableValues: [Double])
}

protocol Interpolator {

    associatedtype InterpolatorKind: ValueInterpolator
    var valueInterpolators: [InterpolatorKind] { get }

    associatedtype Element: Interpolable
    var value: Element { get }
    func update(with newValue: Element) -> Element
}

extension Interpolator {
    func update(with newValue: Element) -> Element {
        let interpolated = zip(newValue.interpolableValues, valueInterpolators).map { (newValue, interpolator) in
            return interpolator.update(with: newValue)
        }
        return Element(interpolableValues: interpolated)
    }
}

protocol ValueInterpolator {
    var value: Double { get }
    func update(with newValue: Double) -> Double
}
