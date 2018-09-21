//
//  RectangleTrackingRegion.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/20/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit


/// A simple rectangular tracking region with a width and height.
struct RectangleTrackingRegion: TrackingRegion {

    let width: CGFloat
    let height: CGFloat

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
