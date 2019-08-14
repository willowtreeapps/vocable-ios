//
//  Bounded.swift
//  EyeSpeak
//
//  Created by Duncan Lewis on 9/20/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

protocol Boundable where Value: Comparable {
    associatedtype Value
    func bounded(by bounds: ClosedRange<Value>) -> Self
}

extension Comparable {

    func bounded(by bounds: ClosedRange<Self>) -> Self {
        return min(bounds.upperBound, max(bounds.lowerBound, self))
    }

}

extension CGPoint: Boundable {
    typealias Value = CGFloat

    func bounded(by bounds: ClosedRange<CGFloat>) -> CGPoint {
        return CGPoint(x: self.x.bounded(by: bounds), y: self.y.bounded(by: bounds))
    }

}
