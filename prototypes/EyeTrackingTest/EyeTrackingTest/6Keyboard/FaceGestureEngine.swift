//
//  FaceGestureEngine.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 5/2/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation
import ARKit

enum EyeState {
    case closed
    case open
    
    static let closedThreshold = NSNumber(0.5)
    
    mutating func update(value: NSNumber) -> Bool {
        if value.floatValue > EyeState.closedThreshold.floatValue && self == .open {
            self = .closed
            return true
        } else if value.floatValue <= EyeState.closedThreshold.floatValue && self == .closed {
            self = .open
            return true
        }
        return false
    }
    
}

class FaceGestureEngine {
    var gestures: [FaceGesture] = []
    
    func update(withAnchor anchor: ARFaceAnchor) {
        for gesture in gestures {
            gesture.update(withAnchor: anchor)
        }
    }
}

struct FaceGestureComponent {
    fileprivate var gestureTimer: Timer?
    fileprivate var currentGestureCount = 0
    fileprivate var isGestureTimerRunning = false
    fileprivate var isGestureDetected = false    
}

protocol FaceGesture: class {
    var gestureTimer: Timer? { get set }
    var currentGestureCount: Int { get set }
    var isGestureTimerRunning: Bool { get set }
    var isGestureDetected: Bool { get set }
    var requiredGestures: Int { get set }
    var onGesture: (() -> Void)? { get set }
    func prepare(withAnchor anchor: ARFaceAnchor)
}

extension FaceGesture {
    func update(withAnchor anchor: ARFaceAnchor) {
        self.prepare(withAnchor: anchor)
        if isGestureDetected {
            if !self.isGestureTimerRunning {
                self.gestureTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                    self.currentGestureCount = 0
                    self.isGestureTimerRunning = false
                })
                self.isGestureTimerRunning = true
            }
            self.currentGestureCount += 1
        }
        if self.currentGestureCount >= self.requiredGestures {
            self.gestureTimer?.invalidate()
            self.isGestureTimerRunning = false
            self.currentGestureCount = 0
            self.onGesture?()
        }
    }
}

class BlinkGesture: FaceGesture {
    var gestureTimer: Timer?
    var currentGestureCount = 0
    var isGestureTimerRunning = false
    var isGestureDetected = false
    var requiredGestures: Int
    var onGesture: (() -> Void)?
    
    
    private var gestureType: ARFaceAnchor.BlendShapeLocation
    private var eyeState: EyeState = .open
    
    init(gestureType: ARFaceAnchor.BlendShapeLocation, requiredGestures: Int) {
        self.gestureType = gestureType
        self.requiredGestures = requiredGestures
    }
    
    func prepare(withAnchor anchor: ARFaceAnchor) {
        self.isGestureDetected = false
        if let value = anchor.blendShapes[gestureType] {
            let didUpdate = self.eyeState.update(value: value)
            self.isGestureDetected = didUpdate && self.eyeState == .open
        }
    }
}

class EyesBlinkGesture: FaceGesture {
    var gestureTimer: Timer?
    var currentGestureCount = 0
    var isGestureTimerRunning = false
    var isGestureDetected = false
    var requiredGestures: Int
    var onGesture: (() -> Void)?
    
    private var leftEyeState: EyeState = .open
    private var rightEyeState: EyeState = .open
    
    init(requiredGestures: Int) {
        self.requiredGestures = requiredGestures
    }
    
    func prepare(withAnchor anchor: ARFaceAnchor) {
        self.isGestureDetected = false
        if let leftEye = anchor.blendShapes[.eyeBlinkLeft], let rightEye = anchor.blendShapes[.eyeBlinkRight] {
            let didUpdateLeft = self.leftEyeState.update(value: leftEye)
            let didUpdateRight = self.rightEyeState.update(value: rightEye)
            self.isGestureDetected = didUpdateLeft && didUpdateRight && self.leftEyeState == .open && self.rightEyeState == .open
        }
    }
}
