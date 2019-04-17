//
//  CircularAnimatable.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/17/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol CircularAnimatable {
    var animationView: UIView { get }
    var animationViewSizeRatio: CGFloat { get }
    var shouldAnimate: Bool { get set }
}

extension CircularAnimatable where Self: TrackingView {
    func animateGaze(withDuration duration: TimeInterval) {
        if self.shouldAnimate {
            self.invalidateAnimationView()
            self.layoutIfNeeded()
            self.animationView.isHidden = false
            
            UIView.animate(withDuration: duration) {
                let tallestSide = self.tallestSide * self.animationViewSizeRatio
                self.animationView.frame = CGRect(x: 0, y: 0, width: tallestSide, height: tallestSide)
                self.animationView.center = self.relativeCenterPoint
                self.animationView.layer.cornerRadius = tallestSide / 2.0
                self.animationView.clipsToBounds = true
                self.layoutIfNeeded()
            }
        }
    }
    
    func cancelAnimation() {
        self.invalidateAnimationView()
    }
    
    func invalidateAnimationView() {
        self.animationView.frame = .zero
        self.animationView.center = self.relativeCenterPoint
        self.animationView.layer.cornerRadius = 0.0
    }
}
