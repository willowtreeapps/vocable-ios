//
//  Interpolation.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 1/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class HeadGazeWindow: UIWindow {

    weak var cursorView: UIVirtualCursorView?

    private var trackingView: UIView?
    private var lastGaze: UIHeadGaze?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
    }

    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        if let trackingView = trackingView, let gaze = lastGaze {
            trackingView.gazeEnded(gaze, with: nil)
        }
        self.trackingView = nil
        self.lastGaze = nil
    }

    override func sendEvent(_ originalEvent: UIEvent) {

        // Ignore any non-gaze events and let super handle them
        guard let event = originalEvent as? UIHeadGazeEvent,
            let gaze = event.allGazes?.first else {
            super.sendEvent(originalEvent)
            return
        }

        lastGaze = event.allGazes?.first

        // If something has registered as the cursor view, let it know
        // there was a state change
        if let cursorView = cursorView {
            cursorView.gazeMoved(gaze, with: event)
        }

        // Locate the current hit-tested view in our hierarchy
        let pointInWindow = gaze.location(in: self)
        let hitTestResult = gazeableHitTest(pointInWindow, with: event)

        guard let trackingView = trackingView, hitTestResult == trackingView else {
            // If we're not continuing to track the same view, end
            // the current tracking session (if one is active) and
            // start a new one with the newly hit-tested view (if non-nil)
            self.trackingView?.gazeEnded(gaze, with: event)
            self.trackingView = hitTestResult
            self.trackingView?.gazeBegan(gaze, with: event)
            return
        }

        // The same view is being tracked, so make sure the cursor
        // hasn't left its area. If it has, end the gaze session for
        // that particular view.
        let point = gaze.location(in: trackingView)
        let isInside = trackingView.point(inside: point, with: nil)
        if isInside {
            trackingView.gazeMoved(gaze, with: event)
        } else {
            trackingView.gazeEnded(gaze, with: event)
            self.trackingView = nil
        }
    }
}

@objc extension UIView {

    var canReceiveGaze: Bool {
        return false
    }

    fileprivate var gazeGestureRecognizers: [UIHeadGazeRecognizer] {
        return self.gestureRecognizers?.compactMap {
            $0 as? UIHeadGazeRecognizer
        } ?? []
    }

    func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        for gestureRecognizer in self.gazeGestureRecognizers {
            gestureRecognizer.gazeBegan(gaze, with: event)
        }
    }

    func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        for gestureRecognizer in self.gazeGestureRecognizers {
            gestureRecognizer.gazeMoved(gaze, with: event)
        }
    }

    func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        for gestureRecognizer in self.gazeGestureRecognizers {
            gestureRecognizer.gazeEnded(gaze, with: event)
        }
    }

    func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        guard !isHidden else { return nil }
        for view in subviews.reversed() {
            let point = view.convert(point, from: self)
            if let result = view.gazeableHitTest(point, with: event) {
                return result
            }
        }
        if self.point(inside: point, with: event) && canReceiveGaze {
            return self
        }
        return nil
    }

}

extension UIControl {

    override var canReceiveGaze: Bool {
        return true
    }

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        self.touchesBegan(Set([gaze]), with: nil)
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        self.touchesMoved(Set([gaze]), with: nil)
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        self.touchesEnded(Set([gaze]), with: nil)
    }
}
