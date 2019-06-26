//
//  FaceGesture.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 6/26/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation
import ARKit

class FaceGesture {
    var gestureTimer: Timer? = nil
    var currentGestureCount = 0
    var isGestureTimerRunning = false
    var isGestureDetected = false
    var requiredGestures = 0
    var onGesture: (() -> Void)? = nil
    
    func prepare(withAnchor anchor: ARFaceAnchor) {}
    
    
    func update(withAnchor anchor: ARFaceAnchor) {
        self.prepare(withAnchor: anchor)
        if isGestureDetected {
            if !self.isGestureTimerRunning {
                self.gestureTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
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
