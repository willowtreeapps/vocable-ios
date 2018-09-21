//
//  QuadrilateralTrackingRegion.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/21/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit


struct QuadrilateralTrackingRegion: TrackingRegion {

    private let interpolator: QuadrilateralInterpolator

    init(quad: Quadrilateral) {
        self.interpolator = QuadrilateralInterpolator(quad: quad)
    }

    func unboundedUnitPosition(for hit: SCNHitTestResult) -> CGPoint? {
        return self.interpolator.unitPosition(ofPointInQuad: CGPoint(x: CGFloat(hit.localCoordinates.x),
                                                                     y: CGFloat(hit.localCoordinates.y)))
    }

}
