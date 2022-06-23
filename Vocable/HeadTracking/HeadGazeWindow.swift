//
//  Interpolation.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 1/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine
import ARKit

class HeadGazeWindow: UIWindow {
    
    weak var cursorView: UIVirtualCursorView?

    var activeGazeTarget: UIView? {
        return trackingView
    }

    private var trackingView: UIView?
    private var lastGaze: UIHeadGaze?
    
    private let touchGazeDisableDuration: TimeInterval = 3
    private var touchGazeDisableBeganDate: Date?
    
    private var cancellables = Set<AnyCancellable>()
    var trackingDisabledByTouch: Bool {
        if let date = touchGazeDisableBeganDate {
            return Date().timeIntervalSince(date) < touchGazeDisableDuration
        }
        return false
    }

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

        AppConfig.$isHeadTrackingEnabled.sink { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.touchGazeDisableBeganDate = .distantPast
            }
        }.store(in: &cancellables)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
    }

    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        cancelCurrentGazeIfNeeded()
    }

    func presentHeadTrackingErrorToastIfNeeded() {
        guard !UIApplication.shared.isGazeTrackingActive, AppConfig.isHeadTrackingEnabled, !trackingDisabledByTouch else {
            return
        }
        let title = String(localized: "gaze_tracking.error.excessive_head_distance.title")
        ToastWindow.shared.presentPersistentWarning(with: title)
    }
    
    private func cancelCurrentGazeIfNeeded() {
        if let trackingView = trackingView, let gaze = lastGaze {
            trackingView.gazeEnded(gaze, with: nil)
        }
        self.trackingView = nil
        self.lastGaze = nil
    }

    private func extendGazeDisabledPeriodForTouchEvent() {
        cancelCurrentGazeIfNeeded()
        
        guard trackingDisabledByTouch == false else { return }
        touchGazeDisableBeganDate = Date()
        ToastWindow.shared.dismissPersistentWarning()
        func schedule(duration: TimeInterval = self.touchGazeDisableDuration) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                let lastTouchDate = self.touchGazeDisableBeganDate ?? .distantPast
                let passed = Date().timeIntervalSince(lastTouchDate)
                if passed >= self.touchGazeDisableDuration {
                    self.cursorView?.setCursorViewsHidden(false, animated: true)
                    self.touchGazeDisableBeganDate = nil
                    self.presentHeadTrackingErrorToastIfNeeded()
                } else {
                    schedule(duration: self.touchGazeDisableDuration - passed)
                }
            }
        }
        schedule(duration: self.touchGazeDisableDuration)
    }

    func animateCursorSelection() {
        cursorView?.animateCursorSelection()
    }

    func cancelActiveGazeTarget() {
        if let lastGaze = lastGaze, let trackingView = trackingView {
            trackingView.gazeCancelled(lastGaze, with: nil)
        }
    }

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        guard let result = super.gazeableHitTest(point, with: event) else {
            return nil
        }
        guard let root = rootViewController?.presentedViewController ?? rootViewController else {
            return result
        }

        func recurseChildren(of vc: UIViewController) -> UIViewController? {

            guard result.isDescendant(of: vc.view) else {
                return nil
            }

            let isBeingPresented = vc.isBeingPresented
            let isBeingDismissed = vc.isBeingDismissed
            let isMovingToParent = vc.isMovingToParent
            let isMovingFromParent = vc.isMovingFromParent
            let isBusy = isBeingPresented || isBeingDismissed || isMovingToParent || isMovingFromParent

            if isBusy {
                return vc
            }

            for child in vc.children {
                if let match = recurseChildren(of: child) {
                    return match
                }
            }

            return nil
        }

        if let _ = recurseChildren(of: root) {
            cancelActiveGazeTarget()
            return result
        }

        return result
    }

    override func sendEvent(_ originalEvent: UIEvent) {

        // Ignore any non-gaze events and let super handle them
        guard let event = originalEvent as? UIHeadGazeEvent,
            let gaze = event.allGazes?.first else {
                if originalEvent.type == .touches {
                    if AppConfig.isHeadTrackingEnabled {
                        extendGazeDisabledPeriodForTouchEvent()
                    }
                    cursorView?.setCursorViewsHidden(true, animated: true)
                }
            super.sendEvent(originalEvent)
            return
        }

        if let gazeDisabledStart = touchGazeDisableBeganDate {
            if Date().timeIntervalSince(gazeDisabledStart) >= touchGazeDisableDuration {
                if !trackingDisabledByTouch {
                    cursorView?.setCursorViewsHidden(false, animated: true)
                }
            } else {
                // Waiting for touch timeout to allow events to propagate
                return
            }
        }

        lastGaze = event.allGazes?.first

        // If something has registered as the cursor view, let it know
        // there was a state change
        cursorView?.gazeMoved(gaze, with: event)

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

    func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        for gestureRecognizer in self.gazeGestureRecognizers {
            gestureRecognizer.gazeCancelled(gaze, with: event)
        }
    }

    func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        guard !isHidden, isUserInteractionEnabled else { return nil }

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
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard canReceiveGaze else { return }
        self.touchesBegan([gaze], with: nil)
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard canReceiveGaze else { return }
        self.touchesMoved(Set([gaze]), with: nil)
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard canReceiveGaze else { return }
        self.touchesEnded(Set([gaze]), with: nil)
    }

    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard canReceiveGaze else { return }
        self.touchesCancelled(Set([gaze]), with: nil)
    }
}
