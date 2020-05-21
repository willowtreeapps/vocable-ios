//
//  InterpolableValues.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 1/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import CoreGraphics

// Extensions of types that we would like to interpolate
// to make them conform to Interpolable

extension CGPoint: Interpolable {
    var interpolableValues: [Double] {
        return [Double(x), Double(y)]
    }
    init(interpolableValues: [Double]) {
        self.init(x: CGFloat(interpolableValues[0]), y: CGFloat(interpolableValues[1]))
    }
}

// MARK: -

extension SIMD2: Interpolable where Scalar == Float {
    var interpolableValues: [Double] {
        return [Double(self[0]), Double(self[1])]
    }
    init(interpolableValues: [Double]) {
        self.init(Float(interpolableValues[0]), Float(interpolableValues[1]))
    }
}
