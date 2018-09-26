//
//  QuadrilateralInterpolator.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/21/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit


/// https://www.particleincell.com/2012/quad-interpolation/
struct QuadrilateralInterpolator {

    let quad: Quadrilateral

    private static let A = simd_double4x4(rows: [
        double4([1, 0, 0, 0]),
        double4([1, 1, 0, 0]),
        double4([1, 1, 1, 1]),
        double4([1, 0, 1, 0])
        ]
    )
    private static let AI = A.inverse

    private let alphaCoefficients: simd_double4 // AI*px
    private let betaCoefficients: simd_double4 // AI*py

    init(quad: Quadrilateral) {
        self.quad = quad

        let xPoints = simd_double4([quad.p1.x, quad.p2.x, quad.p3.x, quad.p4.x].map {Double($0)} )
        let yPoints = simd_double4([quad.p1.y, quad.p2.y, quad.p3.y, quad.p4.y].map {Double($0)} )

        let AI = QuadrilateralInterpolator.AI
        self.alphaCoefficients = simd_mul(AI, xPoints)
        self.betaCoefficients = simd_mul(AI, yPoints)
    }

    func unitPosition(ofPointInQuad point: CGPoint) -> CGPoint {
        let x = Double(point.x)
        let y = Double(point.y)
        let a = self.alphaCoefficients
        let b = self.betaCoefficients

        // quadratic coefficients (1 = x, 2 = y, 3 = z, 4 = w)
        let aa = a.w*b.z - a.z*b.w
        let bb = a.w*b.x - a.x*b.w + a.y*b.z - a.z*b.y + x*b.w - y*a.w
        let cc = a.y*b.x - a.x*b.y + x*b.y - y*a.y

        // m = (-b + sqrt(b^2-4ac)) / 2a
        let determinant = sqrt(pow(bb, 2) - (4*aa*cc))
        var m: Double = 0.0
        if (aa == 0.0) {
            m = (-bb + determinant)
        } else {
            m = (-bb + determinant) / (2*aa)
        }
        let l = (x - a.x - (a.z*m)) / (a.y + (a.w*m))

        return CGPoint(x: l, y: m)
    }

}
