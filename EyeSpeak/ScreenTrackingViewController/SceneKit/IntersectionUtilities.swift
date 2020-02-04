//
//  IntersectionUtilities.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 9/12/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import SceneKit

// enum as namespace
enum IntersectionUtils {

    /// Intersect a line segement, specified in the sourceNode's coordinate system, with the targetNode.
    /// - Returns: The result of hit testing the lineSegment against the targetNode.
    static func intersect(lineSegement: LineSegment, sourceNode: SCNNode, targetNode: SCNNode) -> [SCNHitTestResult] {
        let rayStartInTarget = sourceNode.convertPosition(lineSegement.start.vector3, to: targetNode)
        let rayEndInTarget = sourceNode.convertPosition(lineSegement.end.vector3, to: targetNode)

        return targetNode.hitTestWithSegment(from: rayStartInTarget, to: rayEndInTarget, options: [ SCNHitTestOption.ignoreChildNodes.rawValue: NSNumber(booleanLiteral: true) ])
    }

    /// Given a local-to-world space transform for a line segement, interesct that line segement with the targetNode.
    /// - Returns: The result of hit testing the lineSegment against the targetNode.
    static func intersect(lineSegement: LineSegment, withWorldTransform toWorld: simd_float4x4, targetNode: SCNNode) -> [SCNHitTestResult] {
        let lineStartInWorld = simd_mul(toWorld, lineSegement.start.simdVector4)
        let lineEndInWorld = simd_mul(toWorld, lineSegement.end.simdVector4)

        let lineStartInTarget = targetNode.simdConvertPosition(simd_make_float3(lineStartInWorld), from: nil)
        let lineEndInTarget = targetNode.simdConvertPosition(simd_make_float3(lineEndInWorld), from: nil)

        return targetNode.hitTestWithSegment(from: SCNVector3(lineStartInTarget), to: SCNVector3(lineEndInTarget), options: [ SCNHitTestOption.ignoreChildNodes.rawValue: NSNumber(booleanLiteral: true) ])
    }
    
    // MARK: - Unit-space and Screen-space conversion helpers

    /// Calculates the position of the hit test in the [0.0...1.0] domain using
    /// the coordinate orientation of UIKit (origin in the top left corner).
    static func unitPosition(in plane: SCNPlane, for hit: SCNHitTestResult) -> CGPoint {
        let localX = CGFloat(hit.localCoordinates.x)
        var localY = CGFloat(hit.localCoordinates.y)

        // flip the y coordinate to match UIKit's coordinate system
        localY = -localY

        let unitX = ((plane.width / 2.0) + localX) / plane.width
        let unitY = ((plane.height / 2.0) + localY) / plane.height

        return CGPoint(x: unitX, y: unitY)
    }

    static func screenPosition(fromUnitPosition unitPosition: CGPoint) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        let orientation = UIApplication.shared.statusBarOrientation

        var orientedPosition = unitPosition
        switch orientation {
        case .landscapeLeft:
            orientedPosition.x = 1 - unitPosition.y
            orientedPosition.y = unitPosition.x
        case .landscapeRight:
            orientedPosition.x = unitPosition.y
            orientedPosition.y = 1 - unitPosition.x
        case .portrait:
            break
        case .portraitUpsideDown:
            orientedPosition.x = 1 - orientedPosition.x
            orientedPosition.y = 1 - orientedPosition.y
        case .unknown:
            break
        }

        let screenX = screenSize.width * orientedPosition.x
        let screenY = screenSize.height * orientedPosition.y

        return CGPoint(x: screenX, y: screenY)
    }

}

/*
// Awesome example, thoroughly documented by kevin!
// LEAVE AS IS, even though we have better methods below. This is edification.
func oldAndImportant_updateFacewiseHitTest(faceAnchor: ARFaceAnchor) {
    // Get the position of the face and the position of a point ahead of the nose.
    // Multiplying with the face anchor transform takes a point in its coordinate space
    // and gives us a point in its parent's coordinate space.
    let faceOrigin = simd_mul(faceAnchor.transform, simd_make_float4(0.0, 0.0, 0.0, 1.0))
    let faceEnd = simd_mul(faceAnchor.transform, simd_make_float4(0.0, 0.0, 0.5, 1.0))

    // Get these two positions represented in the coordinate space of the intersection plane.
    // Multiplying with the inverse of the intersection node transform takes a point in its parent's
    //coordinate space and gives us a point in its coordinate space.
    let intersectionPlaneTransform = self.cameraIntersectionPlaneNode.simdTransform
    let inverseIntersectionPlaneTransform = simd_inverse(intersectionPlaneTransform)
    let faceOriginInPlane = simd_mul(inverseIntersectionPlaneTransform, faceOrigin)
    let faceEndInPlane = simd_mul(inverseIntersectionPlaneTransform, faceEnd)

    let hits = self.cameraIntersectionPlaneNode.hitTestWithSegment(from: SCNVector3FromSIMDFloat4(faceOriginInPlane), to: SCNVector3FromSIMDFloat4(faceEndInPlane), options: [ SCNHitTestOption.ignoreChildNodes.rawValue: NSNumber(booleanLiteral: true) ])

    if let firstHit = hits.first {
        if self.faceIntersectionNode.isHidden == true {
            self.faceIntersectionNode.isHidden = false
        }
        self.faceIntersectionNode.position = firstHit.worldCoordinates
        self.faceIntersectionNode.position.z += 0.00001
    }
}
*/
