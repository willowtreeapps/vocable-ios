//
//  TrackingGroup.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

class TrackingGroup: TrackableWidget {
    var id: Int?
    var parent: TrackableWidget?
    
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
    
    var _onGaze: ((Int?) -> Void)?
    
    func animateGaze(withDuration: TimeInterval) {
        self.parent?.animateGaze(withDuration: withDuration)
    }
    
    func cancelAnimation() {
        self.parent?.cancelAnimation()
    }
    
}
