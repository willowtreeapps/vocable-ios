//
//  HeadGazeTrackingInterpolator.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/13/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import ARKit

class HeadGazeTrackingInterpolator {

    private var previousGaze: UIHeadGaze?
    final var event: UIHeadGazeEvent?
    final var view: UIView?
    final var faceAnchor: ARFaceAnchor?
    var needsResetOnNextUpdate = true

    private var lastGazeNDCLocation = CGPoint(x: 0.5, y: 0.5)

    func interpolateNDCLocation(_ point: SIMD2<Float>) -> SIMD2<Float> {
        return point
    }

    func interpolateCursorLocation(_ point: CGPoint) -> CGPoint {
        return point
    }

    final func update(withFrame frame: ARFrame, correctionAmount: CGSize, scale: CGFloat) {

        guard let faceAnchor = faceAnchor, let view = view else { return }

        let blendShapes = faceAnchor.blendShapes
        let lBlinkAmount = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        let rBlinkAmount = blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0

        let blinkThreshold: Float = 0.3
        let leftBlink = lBlinkAmount > blinkThreshold
        let rightBlink = rBlinkAmount > blinkThreshold
        let isBlinking = leftBlink || rightBlink

        let cursorPosNDC: CGPoint
        if !isBlinking && faceAnchor.isTracked {

            let pos = updateGazeNDCLocationByARFaceAnchor(frame: frame, isBlinking: isBlinking, correctionAmount: correctionAmount, scale: scale)
            cursorPosNDC = interpolateCursorLocation(pos)
            lastGazeNDCLocation = pos
        } else {
            cursorPosNDC = interpolateCursorLocation(lastGazeNDCLocation)
        }

        guard let window = view.window else { return }

        if faceAnchor.isTracked {

            // Generate head gaze event and invoke event callback methods
            var allGazes = Set<UIHeadGaze>()
            let curGaze: UIHeadGaze
            if let lastGaze = previousGaze {
                curGaze = UIHeadGaze(curPosition: cursorPosNDC, prevPosition: lastGaze.location(in: window), view: view, win: window)
            } else {
                curGaze = UIHeadGaze(position: cursorPosNDC, view: view, win: window)
            }

            allGazes.insert(curGaze)
            previousGaze = curGaze
            event = UIHeadGazeEvent(allGazes: allGazes)

        } else {
            // Ensure that the interpolators will reset on the next frame
            // that a face is actually trackable. This is to prevent
            // the cursor jumping wildly when first (re-)entering the view
            needsResetOnNextUpdate = true
            previousGaze = nil
            event = nil
        }
    }

    /**
     return head gaze projection in 2D NDC coordinate system
     where the origin is at the center of the screen
     */
    private func updateGazeNDCLocationByARFaceAnchor(frame: ARFrame, isBlinking: Bool, correctionAmount: CGSize, scale: CGFloat) -> CGPoint {

        let worldTransMtx = getFaceTransformationMatrix()

        let o_headCenter = simd_float4(0, 0, 0, 1)
        let o_headLookAtDir  = simd_float4(0, 0, 1, 0)

        let tranfMtx = worldTransMtx
        let c_headCenter = tranfMtx * o_headCenter
        let c_lookAtDir  = tranfMtx * o_headLookAtDir
        let t = (0.0 - c_headCenter[2]) / c_lookAtDir[2]
        let hitPos = c_headCenter + c_lookAtDir * t

        let correctionScalar: CGFloat = 1.0
        let xNDC = Float(hitPos[0]) - Float(correctionAmount.width * correctionScalar)
        let yNDC = Float(hitPos[1]) - Float(correctionAmount.height * correctionScalar)
        let hitPosNDC = SIMD2<Float>([xNDC, yNDC])
        let filteredPos: SIMD2<Float>
        filteredPos = interpolateNDCLocation(hitPosNDC)

        let worldToSKSceneScale = Float(scale)
        let hitPosSKScene = filteredPos * worldToSKSceneScale

        let orientation = view?.window?.windowScene?.interfaceOrientation ?? .portrait
        switch orientation {
        case .portrait:
            return CGPoint(x: CGFloat(hitPosSKScene[1]), y: -CGFloat(hitPosSKScene[0]))
        case .portraitUpsideDown:
            return CGPoint(x: -CGFloat(hitPosSKScene[1]), y: CGFloat(hitPosSKScene[0]))
        case .landscapeRight:
            return CGPoint(x: CGFloat(hitPosSKScene[0]), y: CGFloat(hitPosSKScene[1]))
        case .landscapeLeft:
            return CGPoint(x: -CGFloat(hitPosSKScene[0]), y: -CGFloat(hitPosSKScene[1]))
        case .unknown:
            fallthrough
        @unknown default:
            return CGPoint(x: CGFloat(hitPosSKScene[0]), y: CGFloat(hitPosSKScene[1]) )
        }
    }

    /**
     Returns the world transformation matrix of the ARFaceAnchor node
     */
    private func getFaceTransformationMatrix() -> simd_float4x4 {
        return faceAnchor?.transform ?? .identity
    }

    /**
     Extract the scale components of the ARFaceAnchor node
    */
    private func getFaceScale() -> simd_float3 {
        let M = getFaceTransformationMatrix()
        let sx = simd_float3([M[0][0], M[0][1], M[0][2]])
        let sy = simd_float3([M[1][0], M[1][1], M[1][2]])
        let sz = simd_float3([M[2][0], M[2][1], M[2][2]])
        let s = simd_float3([simd_length(sx), simd_length(sy), simd_length(sz)])
        return s
    }

    /**
     Extract the rotation components of the ARFaceAnchor node
     */
    private func getFaceRotationMatrix() -> simd_float4x4 {
        let scale = getFaceScale()
        let mtx = getFaceTransformationMatrix()
        var (c0, c1, c2, c3) = mtx.columns
        c3 = simd_float4(0, 0, 0, 1) //zero out translation components
        c0 /= scale[0]
        c1 /= scale[1]
        c2 /= scale[2]
        return simd_float4x4(c0, c1, c2, c3)
    }
}

final class PIDControlledTrackingInterpolator: HeadGazeTrackingInterpolator {

    override var needsResetOnNextUpdate: Bool {
        didSet {
            pidSmoothingInterpolator.needsResetOnNextUpdate = needsResetOnNextUpdate
        }
    }

    private(set) var pidSmoothingInterpolator: PIDInterpolator<CGPoint> = {
        let interpolator = PIDInterpolator<CGPoint>(initialValue: .zero)
        interpolator.needsResetOnNextUpdate = true
        return interpolator
    }()

    override func interpolateNDCLocation(_ point: SIMD2<Float>) -> SIMD2<Float> {
        return point
    }

    override func interpolateCursorLocation(_ point: CGPoint) -> CGPoint {
        return pidSmoothingInterpolator.update(with: point)
    }
}

final class LowPassTrackingInterpolator: HeadGazeTrackingInterpolator {

    override var needsResetOnNextUpdate: Bool {
        didSet {
            cursorPositionInterpolator.needsResetOnNextUpdate = needsResetOnNextUpdate
            ndcSmoothingInterpolator.needsResetOnNextUpdate = needsResetOnNextUpdate
        }
    }

    private var cursorPositionInterpolator: LowPassInterpolator<CGPoint> = {
        let interpolator = LowPassInterpolator<CGPoint>(filterFactor: 0.8, initialValue: .zero)
        interpolator.needsResetOnNextUpdate = true
        return interpolator
    }()

    private var ndcSmoothingInterpolator: LowPassInterpolator<SIMD2<Float>> = {
        let interpolator = LowPassInterpolator<SIMD2<Float>>(filterFactor: 0.05, initialValue: .zero)
        interpolator.needsResetOnNextUpdate = true
        return interpolator
    }()

    override func interpolateNDCLocation(_ point: SIMD2<Float>) -> SIMD2<Float> {
        return ndcSmoothingInterpolator.update(with: point)
    }

    override func interpolateCursorLocation(_ point: CGPoint) -> CGPoint {
        return cursorPositionInterpolator.update(with: point)
    }
}
