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
    fileprivate var _beforeAnimationSize: CGSize = .zero
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
    fileprivate var beforeAnimationSize: CGSize {
        get {
            return self.animatableComponent._beforeAnimationSize
        } set {
            self.animatableComponent._beforeAnimationSize = newValue
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
            self.beforeAnimationSize = self.frame.size
            let center = self.center
            let newWidth = self.beforeAnimationSize.width * self.expandingScale
            let newHeight = self.beforeAnimationSize.height * self.expandingScale
            self.willExpand()
            UIView.animate(withDuration: self.animationSpeed, animations:  {
                self.frame = CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight))
                self.center = center
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
            let center = self.center
            self.willCollapse()
            UIView.animate(withDuration: 1.0, animations: {
                self.frame = CGRect(origin: .zero, size: self.beforeAnimationSize)
                self.center = center
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
