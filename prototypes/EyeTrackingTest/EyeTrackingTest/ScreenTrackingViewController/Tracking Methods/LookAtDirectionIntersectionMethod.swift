//
//  LookAtDirectionTrackingMethod.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

class LookAtDirectionTrackingMethod: TrackingMethod {

    func intersect(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> SCNHitTestResult? {
        let intersectionLine = LineSegment(start: SCNVector4(0.0, 0.0, 0.0, 1.0), end: SCNVector4(faceAnchor.lookAtPoint, w: 0.0))
        let hits = IntersectionUtils.intersect(lineSegement: intersectionLine, withWorldTransform: faceAnchor.transform, targetNode: hitTestNode)

        return hits.first
    }

}
