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
    init(isTrackingEnabled: Bool) {
        self._isTrackingEnabled = isTrackingEnabled
    }
    fileprivate var _isTrackingEnabled: Bool = true
}

protocol ExpandingAnimatable: class {
    var expandingScale: CGFloat { get set }
    var animatableState: ExpandingAnimatableState { get set }
    var animatableComponent: ExpandingAnimatableComponent { get set }
}

extension ExpandingAnimatable where Self: TrackingView {
    var isTrackingEnabled: Bool {
        get {
            return self.animatableComponent._isTrackingEnabled && self.animatableState != .shrinking
        }
        set {
            self.animatableComponent._isTrackingEnabled = newValue
        }
    }
    func animateGaze() {
        print("animateGaze")
        if self.animatableState == .idle {
            print("Expanding")
            self.animatableState = .expanding
            UIView.animate(withDuration: self.animationSpeed, animations:  {
                print("Inside expanding animation")
                self.transform = CGAffineTransform(scaleX: self.expandingScale, y: self.expandingScale)
            }, completion: { finished in
                if self.animatableState == .expanding {
                    print("Expanded")
                    self.animatableState = .expanded
                }
            })
        }
    }
    
    func cancelAnimation() {
        print("cancelAnimation")
        if self.animatableState.isGazing {
            print("Shrinking")
            self.animatableState = .shrinking
            UIView.animate(withDuration: 1.0, animations: {
                print("Inside cancel animation")
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { finished in
                if self.animatableState == .shrinking {
                    print("Idle")
                    self.animatableState = .idle
                }
            })
        }
    }
}
