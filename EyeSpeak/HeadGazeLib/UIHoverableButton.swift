// Copyright 2018 eBay Inc.
// Architect/Developer: Jinrong Xie, Muratcan Cicek
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import UIKit

/**
 By default the hoverable button increases it's size when the cursor is hovering over it, and trigger selection action when it completes its dialation animation. Similarily, it decreases its size, and trigger deselection action when it completes its shrinking animation.
 Subclass of UIHoverableButton can customize the animation of hovering by overriding methods hoverAnimation() and deHoverAnimation()
 Override methods select() and deselect() to define what to do whenever the button completes animation.
 */
class UIHoverableButton: UIButton {

    private let hoverScale: Float = 1.3 // The scaling factor when the button is hovered over
    private let inAlpha: CGFloat = 1.0 // The button alpha when it is hovered over
    private let outAlpha: CGFloat = 0.5 // The button alpha when it is not hovered over
    private let dwellDuration: CGFloat = 1.0

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        self.isHighlighted = true
        beginGazeAnimation()
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeEnded(gaze, with: event)
        self.isHighlighted = false
        self.isSelected = false
        endHoverAnimation()
    }

    private func beginGazeAnimation() {
        guard isHighlighted else {
            return
        }
        UIView.animate(withDuration: TimeInterval(dwellDuration), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: {
            self.alpha = self.inAlpha
            self.transform = CGAffineTransform(scaleX: CGFloat(self.hoverScale), y: CGFloat(self.hoverScale))
        }, completion: { (didFinish) in
            if didFinish {
                if self.isHighlighted {
                    self.isSelected = true
                    self.sendActions(for: .primaryActionTriggered)
                }
                self.beginPulseAnimation()
            }
        })
    }

    private func beginPulseAnimation() {
        guard isHighlighted else {
            return
        }
        UIView.animateKeyframes(withDuration: TimeInterval(dwellDuration) * 1.5, delay: 0, options: .beginFromCurrentState, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.33) {
                let pulseIntermediateScale: CGFloat = 0.9
                self.transform = CGAffineTransform(scaleX: CGFloat(self.hoverScale) * pulseIntermediateScale, y: CGFloat(self.hoverScale) * pulseIntermediateScale)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.33, relativeDuration: 0.66) {
                self.transform = CGAffineTransform(scaleX: CGFloat(self.hoverScale), y: CGFloat(self.hoverScale))
            }
        }) { (didFinish) in
            if didFinish {
                self.beginPulseAnimation()
            }
        }
    }

    private func endHoverAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .beginFromCurrentState, animations: {
            self.alpha = self.outAlpha
            self.transform = .identity
        }, completion: nil)
    }
    
}
