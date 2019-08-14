//
//  CircularAnimatable.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/17/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

struct CircularAnimatableComponent {
    fileprivate var _animatableState: AnimatingState = .idle
}

protocol CircularAnimatable: class {
    var animationView: UIView { get }
    var animationViewDiameter: CGFloat { get }
    var hoverBorderColor: UIColor? { get set }
    var statelessBorderColor: UIColor? { get set }
    var animatableComponent: CircularAnimatableComponent { get set }
}

extension CircularAnimatable where Self: TrackingView {
    var animationViewDiameter: CGFloat {
        let height = self.frame.height
        let width = self.frame.width
        let requiredDiameter = sqrt(height * height + width * width)
        return requiredDiameter
    }
    fileprivate var animatableState: AnimatingState {
        get {
            return self.animatableComponent._animatableState
        } set {
            self.animatableComponent._animatableState = newValue
        }
    }
    
    func animateGaze() {
        if self.isTrackingEnabled && (self.animatableState == .idle || self.animatableState == .cancelled) {
            self.animationView.center = self.relativeCenterPoint
            self.animationView.bounds = .zero
            self.animationView.layer.cornerRadius = 0.0
            self.animationView.isHidden = false
            self.isTrackingEnabled = false
            self.animatableState = .expanding
            self.layer.borderColor = self.hoverBorderColor?.cgColor
            UIView.animate(withDuration: self.animationSpeed, animations: {
                self.animationView.bounds = CGRect(x: -(self.animationViewDiameter / 2), y: -(self.animationViewDiameter / 2), width: self.animationViewDiameter, height: self.animationViewDiameter)
                self.animationView.layer.cornerRadius = self.animationViewDiameter / 2.0
                self.animationView.clipsToBounds = true
            }, completion: { finished in
                if self.animatableState == .expanding && finished {
                    self.animatableState = .expanded
                }
            })
        }
    }
    
    func cancelAnimation() {
        self.invalidateAnimationView()
    }
    
    func invalidateAnimationView() {
        if self.animatableState.isGazing {
            self.animatableState = .shrinking
            UIView.animate(withDuration: 1.0, animations: {
                self.layer.borderColor = self.statelessBorderColor?.cgColor
                self.animationView.bounds = .zero
                self.animationView.layer.cornerRadius = 0.0
            }, completion: { finished in
                if self.animatableState == .shrinking && finished {
                    self.animatableState = .idle
                    self.isTrackingEnabled = true
                }
            })
        }
    }
}
