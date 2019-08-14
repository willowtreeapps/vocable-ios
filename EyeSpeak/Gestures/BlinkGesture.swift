//
//  BlinkGesture.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 6/26/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation
import ARKit

class BlinkGesture: FaceGesture {
    private var gestureType: ARFaceAnchor.BlendShapeLocation
    private var eyeState: EyeState = .open
    
    init(gestureType: ARFaceAnchor.BlendShapeLocation, requiredGestures: Int) {
        self.gestureType = gestureType
        super.init()
        self.requiredGestures = requiredGestures
    }
    
    override func prepare(withAnchor anchor: ARFaceAnchor) {
        self.isGestureDetected = false
        if let value = anchor.blendShapes[gestureType] {
            let didUpdate = self.eyeState.update(value: value)
            self.isGestureDetected = didUpdate && self.eyeState == .open
        }
    }
}
