// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit

class UIHeadGazeEvent: UIEvent {
    public var allGazes: Set<UIHeadGaze>?
    override var allTouches: Set<UITouch>? {
        return allGazes
    }

    /**
     The time when the event occurred
     */
    private var _timestamp: TimeInterval
    
    /**
     Returns the time when the event occurred
     */
    public var timeStamp: TimeInterval{
        return _timestamp
    }
    
    init(allGazes: Set<UIHeadGaze>? = nil) {
        self.allGazes = allGazes
        self._timestamp = Date().timeIntervalSince1970
    }
}
