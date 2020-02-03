//
//  InterpolableValues.swift
//  demo
//
//  Created by Chris Stroud on 1/31/20.
//  Copyright © 2020 Xie,Jinrong. All rights reserved.
//

import Foundation
import CoreGraphics

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
