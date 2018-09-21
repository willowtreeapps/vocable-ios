//
//  TrackingRegion.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/20/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit

protocol TrackingRegion {

    /// Calculates the position of the hit in the tracking region, in the region's
    /// unit space.
    ///
    /// The position returned is in the unit space ([0.0...1.0]) of the tracking region,
    /// oriented in UIKit's coordinate orientation (origin in the top left corner).
    func unitPosition(for hit: SCNHitTestResult) -> CGPoint?

    /// Calculates the position of the hit in the tracking region, relative to but not
    /// bounded by the region's unit space.
    ///
    /// Similar to `unitPosition(for:)`, the position returned is relative to the
    /// unit space of the tracking region ([0.0...1.0]), but is not bounded by that space.
    /// This method can be used to calculate a position "outside" of the region.
    func unboundedUnitPosition(for hit: SCNHitTestResult) -> CGPoint?

}

/// Default unitPosition implementation derived from the unboundedUnitPosition method
extension TrackingRegion {

    func unitPosition(for hit: SCNHitTestResult) -> CGPoint? {
        return self.unboundedUnitPosition(for: hit)?.bounded(by: .unitRange)
    }

}
