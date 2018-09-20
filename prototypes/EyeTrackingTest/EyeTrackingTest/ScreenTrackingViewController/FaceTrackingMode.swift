//
//  FaceTrackingMode.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/11/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import Foundation

// TODO: rename to FaceTrackingConfiguration, add tracking region
enum FaceTrackingMode {
    case head
    case eye

    var trackingMethod: TrackingMethod {
        switch self {
        case .head:
            return HeadDirectionTrackingMethod()
        case .eye:
            return LookAtDirectionTrackingMethod()
        }
    }
}
