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
    public var timeStamp: TimeInterval {
        return _timestamp
    }
    
    init(allGazes: Set<UIHeadGaze>? = nil) {
        self.allGazes = allGazes
        self._timestamp = Date().timeIntervalSince1970
    }
}
