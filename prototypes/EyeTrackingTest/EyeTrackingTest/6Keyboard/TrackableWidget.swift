//
//  TrackableWidget.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

struct GazeableTrackingComponent {
    fileprivate var _onGaze: ((Int?) -> Void)?
}

protocol TrackableWidget: Gazeable {
    var parent: TrackableWidget? { get set }
    var id: Int? { get set }
    var gazeableComponent: GazeableTrackingComponent { get set }
    func add(to engine: TrackingEngine)
}

extension TrackableWidget {
    var onGaze: ((Int?) -> Void)? {
        get {
            guard let componentOnGaze = self.gazeableComponent._onGaze else { return self.parent?.onGaze }
            return componentOnGaze
        }
        set {
            self.gazeableComponent._onGaze = newValue
        }
    }
}
