//
//  Quadrilateral.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/21/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit


struct Quadrilateral {
    let p1: CGPoint
    let p2: CGPoint
    let p3: CGPoint
    let p4: CGPoint

    var points: [CGPoint] {
        return [p1, p2, p3, p4]
    }

}
