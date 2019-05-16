//
//  ExpandingAnimatable.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/18/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

enum ExpandingAnimatableState {
    case idle
    case shrinking
    case expanding
    case expanded
    
    var isGazing: Bool {
        return self == .expanding || self == .expanded
    }
}

struct ExpandingAnimatableComponent {
    fileprivate var _beforeAnimationBounds: CGRect = .zero
    fileprivate var _animatableState: ExpandingAnimatableState = .idle
    fileprivate var _isTrackingEnabled: Bool = false
}

protocol ExpandingAnimatable: class {
    var expandingScale: CGFloat { get set }
    var animatableComponent: ExpandingAnimatableComponent { get set }
    func willExpand()
    func onExpand()
    func willCollapse()
    func onCollapse()
}

extension ExpandingAnimatable where Self: HotCornerView {
    fileprivate var beforeAnimationBounds: CGRect {
        get {
            return self.animatableComponent._beforeAnimationBounds
        } set {
            self.animatableComponent._beforeAnimationBounds = newValue
        }
    }
    fileprivate var animatableState: ExpandingAnimatableState {
        get {
            return self.animatableComponent._animatableState
        } set {
            self.animatableComponent._animatableState = newValue
        }
    }
    
    func animateGaze() {
        if self.isTrackingEnabled && self.animatableState == .idle {
            self.isTrackingEnabled = false
            self.animatableState = .expanding
            self.beforeAnimationBounds = self.bounds
            let newSize = self.beforeAnimationBounds.size.multiply(by: self.expandingScale)
            let newOrigin = self.beforeAnimationBounds.origin.multiply(by: self.expandingScale)
            self.willExpand()
            UIView.animate(withDuration: self.animationSpeed, animations:  {
                self.bounds = CGRect(origin: newOrigin, size: newSize)
                self.onExpand()
                
            }, completion: { finished in
                if self.animatableState == .expanding && finished {
                    self.animatableState = .expanded
                }
            })
        }
    }
    
    func cancelAnimation() {
        if self.animatableState.isGazing {
            self.animatableState = .shrinking
            self.willCollapse()
            UIView.animate(withDuration: 1.0, animations: {
                self.bounds = self.beforeAnimationBounds
                self.onCollapse()
            }, completion: { finished in
                if self.animatableState == .shrinking && finished {
                    self.animatableState = .idle
                    self.isTrackingEnabled = true
                }
            })
        }
    }
}
