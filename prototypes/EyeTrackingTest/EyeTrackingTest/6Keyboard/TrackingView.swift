//
//  TrackingView.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/5/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

typealias TrackingView = UIView & TrackableWidget

protocol Gazeable: AnyObject {
    var onGaze: ((Int?) -> Void)? { get set }
    var animationSpeed: TimeInterval { get set }
    func animateGaze()
    func cancelAnimation()
}
