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
    
    lazy var animationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.animatingColor
        self.addSubview(view)
        self.sendSubviewToBack(view)
        return view
    }()
    
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
    
    func animateGaze(withDuration duration: TimeInterval) {
        self.collapseAnimationView()
        self.layoutIfNeeded()
        
        self.animationView.isHidden = false
        UIView.animate(withDuration: duration) {
            let tallestSide = self.tallestSide + 20.0
            self.animationView.frame = CGRect(x: 0, y: 0, width: tallestSide, height: tallestSide)
            self.animationView.center = self.relativeCenterPoint
            self.animationView.layer.cornerRadius = tallestSide / 2.0
            self.animationView.clipsToBounds = true
            self.layoutIfNeeded()
        }
    }
    
    func cancelAnimation() {
        self.animationView.isHidden = true
        self.collapseAnimationView()
    }
    
    func collapseAnimationView() {
        self.animationView.frame = .zero
        self.animationView.center = self.relativeCenterPoint
        self.animationView.layer.cornerRadius = 0.0
    }

}
