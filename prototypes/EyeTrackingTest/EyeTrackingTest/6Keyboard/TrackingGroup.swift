//
//  TrackingGroup.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

class TrackingGroup: TrackableWidget {
    var isTrackingEnabled: Bool {
        get {
            return !self.widgets.map { $0.isTrackingEnabled }.contains(false)
        }
        set {
            self.widgets.forEach { widget in
                widget.isTrackingEnabled = newValue
            }
        }
    }
    var animationSpeed: TimeInterval = 1.0
    var id: Int?
    var parent: TrackableWidget?
    var gazeableComponent = GazeableTrackingComponent()
    
    let widgets: [TrackableWidget]
    
    init(widgets: [TrackableWidget] = []) {
        self.widgets = widgets
        self.widgets.enumerated().forEach { tuple in
            let (index, widget) = tuple
            widget.parent = self
            widget.id = index
        }
    }
    
    func add(to engine: TrackingEngine) {
        for widget in widgets {
            widget.add(to: engine)
        }
    }
    
    func animateGaze() {
        self.parent?.animateGaze()
    }
    
    func cancelAnimation() {
        self.parent?.cancelAnimation()
    }
    
}
