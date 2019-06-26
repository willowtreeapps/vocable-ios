//
//  FaceGestureEngine.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 5/2/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation
import ARKit

class FaceGestureEngine {
    var gestures: [FaceGesture] = []
    
    func update(withAnchor anchor: ARFaceAnchor) {
        for gesture in gestures {
            gesture.update(withAnchor: anchor)
        }
    }
}
