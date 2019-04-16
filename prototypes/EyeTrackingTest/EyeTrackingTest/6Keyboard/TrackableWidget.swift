//
//  TrackableWidget.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol TrackableWidget: Gazeable {
    var parent: TrackableWidget? { get set }
    var id: Int? { get set }
    func add(to engine: TrackingEngine)
}
