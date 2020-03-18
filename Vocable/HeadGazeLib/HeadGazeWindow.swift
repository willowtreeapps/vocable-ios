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
    
    private weak var warningView: UIView?
    private weak var phraseSavedView: UIView?

    private var trackingView: UIView?
    private var lastGaze: UIHeadGaze?
    private let touchGazeDisableDuration: TimeInterval = 3
    private var touchGazeDisableBeganDate: Date?
    
    private var headTrackingEnabledPublisher: AnyCancellable?

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

        headTrackingEnabledPublisher = AppConfig.$isHeadTrackingEnabled.sink { [weak self] isEnabled in
            DispatchQueue.main.async {
                self?.updateForCurrentHeadTrackingAvailability(isEnabled: isEnabled)
            }
        }
        updateForCurrentHeadTrackingAvailability(isEnabled: AppConfig.isHeadTrackingEnabled)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .headTrackingDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(phraseSaved), name: .phraseSaved, object: nil)
    }

    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        cancelCurrentGazeIfNeeded()
        handleWarning(shouldDisplay: true)
    }
    
    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        handleWarning(shouldDisplay: false)
    }
    
    @objc private func headTrackingDisabled(_ sender: Any?) {
        handleWarning(shouldDisplay: false)
    }
    
    @objc private func phraseSaved(_ sender: Any?) {

        if phraseSavedView == nil {
            let phraseSavedView = UINib(nibName: "PhraseSavedView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
            phraseSavedView.alpha = 0
            self.phraseSavedView = phraseSavedView
            addSubview(phraseSavedView)
            phraseSavedView.translatesAutoresizingMaskIntoConstraints = false

            let horizontalPadding: CGFloat = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) ? 16 : 24
            NSLayoutConstraint.activate([
                phraseSavedView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                phraseSavedView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor,
                                                      constant: horizontalPadding),
                phraseSavedView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor,
                                                       constant: horizontalPadding),
                phraseSavedView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
                phraseSavedView.centerYAnchor.constraint(equalTo: centerYAnchor),
                phraseSavedView.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        }
        UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: [.beginFromCurrentState], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                self.phraseSavedView?.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                self.phraseSavedView?.alpha = 0
            }
        }, completion: { [weak self] didFinish in
            if didFinish {
                self?.phraseSavedView?.removeFromSuperview()
            }
        })
    }

    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        if let cursorView = cursorView {
            bringSubviewToFront(cursorView)
        }
        if let warningView = warningView {
            bringSubviewToFront(warningView)
        }
        if let phraseSavedView = phraseSavedView {
            bringSubviewToFront(phraseSavedView)
        }
    }
    
    private func handleWarning(shouldDisplay: Bool) {

        if warningView == nil {
            let warningView = UINib(nibName: "WarningView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
            warningView.alpha = 0
            self.warningView = warningView
            addSubview(warningView)
            warningView.translatesAutoresizingMaskIntoConstraints = false
            warningView.setContentHuggingPriority(.required, for: .horizontal)
            let horizontalPadding: CGFloat = [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) ? 16 : 24
            NSLayoutConstraint.activate([
                warningView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                warningView.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: horizontalPadding),
                warningView.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: horizontalPadding),
                warningView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
            ])
        }

        let alphaValue = shouldDisplay ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: {
            self.warningView?.alpha = CGFloat(alphaValue)
        }, completion: { [weak self] didFinish in
            if didFinish && !shouldDisplay {
                self?.warningView?.removeFromSuperview()
            }
        })
    }

    private func cancelCurrentGazeIfNeeded() {
        if let trackingView = trackingView, let gaze = lastGaze {
            trackingView.gazeEnded(gaze, with: nil)
        }
        self.trackingView = nil
        self.lastGaze = nil
    }

    private func updateForCurrentHeadTrackingAvailability(isEnabled: Bool) {
        if isEnabled {
            self.installCursorViewIfNeeded()
            self.touchGazeDisableBeganDate = .distantPast
        } else {
            self.cursorView?.removeFromSuperview()
            handleWarning(shouldDisplay: false)
        }
    }

    private func extendGazeDisabledPeriodForTouchEvent() {
        cancelCurrentGazeIfNeeded()
        touchGazeDisableBeganDate = Date()
    }

    private func installCursorViewIfNeeded() {
        guard cursorView?.superview == nil else { return }

        let cursorView = UIVirtualCursorView()
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cursorView)

        NSLayoutConstraint.activate([
            cursorView.topAnchor.constraint(equalTo: topAnchor),
            cursorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cursorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cursorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.cursorView = cursorView
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
                    extendGazeDisabledPeriodForTouchEvent()
                    cursorView?.setCursorViewsHidden(true, animated: true)
                }
            super.sendEvent(originalEvent)
            return
        }

        if let gazeDisabledStart = touchGazeDisableBeganDate {
            if Date().timeIntervalSince(gazeDisabledStart) >= touchGazeDisableDuration {
                cursorView?.setCursorViewsHidden(false, animated: true)
                touchGazeDisableBeganDate = nil
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
