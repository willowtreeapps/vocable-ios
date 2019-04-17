//
//  TrackingTextView.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/17/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class TrackingTextView: UITextView, TrackableWidget, CircularAnimatable {
    var parent: TrackableWidget?
    
    var id: Int?
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }
    
    lazy var animationView: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.backgroundColor = UIColor.animatingColor
        return view
    }()
    
    var animationViewSizeRatio: CGFloat {
        return 4.0 / 3.0
    }
    
    var shouldAnimate: Bool = true
    
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
    
    
}
