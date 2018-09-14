//
//  TrackingPlaneNode.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

class TrackingPlaneNode: SCNNode {

    // MARK: - Configuration

    // todo: add tracking region

    var trackingMethod: TrackingMethod


    // MARK: - Face Tracking

    func track(faceAnchor: ARFaceAnchor) -> TrackingResult? {
        guard let hitTest = trackingMethod.intersect(faceAnchor: faceAnchor, withHitTestNode: self) else {
            return nil
        }

        let unitPosition = IntersectionUtils.unitPosition(in: self.hitTestPlane, for: hitTest)
        return TrackingResult(hitTest: hitTest, unitPositionInPlane: unitPosition)
    }


    // MARK: -

    init(trackingMethod: TrackingMethod) {
        self.trackingMethod = trackingMethod
        super.init()
        self.geometry = self.hitTestPlane
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }


    // MARK: -

    private let hitTestPlane: SCNPlane = {
        let plane = SCNPlane(width: Constants.phoneScreenSize.width, height: Constants.phoneScreenSize.height)
        plane.materials.first?.diffuse.contents = UIColor.white
        plane.materials.first?.transparency = 0.3
        plane.materials.first?.isDoubleSided = true
        return plane
    }()

}
