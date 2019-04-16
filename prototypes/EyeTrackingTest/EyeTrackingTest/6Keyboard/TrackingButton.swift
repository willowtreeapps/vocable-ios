//
//  TrackingButton.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/6/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit


class TrackingButton: UIButton, TrackableWidget {
    var id: Int?
    var parent: TrackableWidget?
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }

    private var _onGaze: ((Int?) -> Void)?

    var onGaze: ((Int?) -> Void)? {
        get {
            if self._onGaze == nil { return self.parent?.onGaze }
            return self._onGaze
            
        }
        set {
            self._onGaze = newValue
        }
    }
    
    func animateGaze(withDuration: TimeInterval) {}
    
    func cancelAnimation() {}

}
