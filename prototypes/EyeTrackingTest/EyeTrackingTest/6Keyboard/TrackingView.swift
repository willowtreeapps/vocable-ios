//
//  TrackingView.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/5/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

typealias TrackingView = Gazeable & UIView

protocol Gazeable: AnyObject {

    var onGaze: (() -> Void)? { get set }
    func animateGaze(withDuration: TimeInterval)
    func cancelAnimation()

}
