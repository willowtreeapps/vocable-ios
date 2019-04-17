//
//  TrackableWidget.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol TrackableWidget: Gazeable {
    var _onGaze: ((Int?) -> Void)? { get set }
    var parent: TrackableWidget? { get set }
    var id: Int? { get set }
    func add(to engine: TrackingEngine)
}

extension TrackableWidget {
    var onGaze: ((Int?) -> Void)? {
        get {
            if self._onGaze == nil { return self.parent?.onGaze }
            return self._onGaze
        }
        set {
            self._onGaze = newValue
        }
    }
}
