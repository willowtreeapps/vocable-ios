//
//  RectangleTrackingRegion.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/20/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit

struct RectangleTrackingRegion: TrackingRegion {

    let width: CGFloat
    let height: CGFloat

    func unitPosition(for hit: SCNHitTestResult) -> CGPoint? {
        return self.unboundedUnitPosition(for: hit)?.bounded(by: .unitRange)
    }

    func unboundedUnitPosition(for hit: SCNHitTestResult) -> CGPoint? {
        let localX = CGFloat(hit.localCoordinates.x)
        var localY = CGFloat(hit.localCoordinates.y)

        // flip the y coordinate to match UIKit's coordinate system
        localY = -localY

        let unitX = ((self.width / 2.0) + localX) / self.width
        let unitY = ((self.height / 2.0) + localY) / self.height

        return CGPoint(x: unitX, y: unitY)
    }

}
