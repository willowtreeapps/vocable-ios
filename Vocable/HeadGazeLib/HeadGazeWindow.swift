//
//  Interpolation.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 1/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class HeadGazeWindow: UIWindow {

    let cursorView = UIVirtualCursorView()
    
    var warningView = UIView()
    var phraseSavedView = UIView()

    private var trackingView: UIView?
    private var lastGaze: UIHeadGaze?
    private let touchGazeDisableDuration: TimeInterval = 3
    private var touchGazeDisableBeganDate: Date?
    
    private var disposables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()

        cursorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(cursorView)
        initializeWarningView()
        initializePhraseSaveView()
        
        NSLayoutConstraint.activate([
            cursorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            cursorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            cursorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            cursorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        _ = AppConfig.headTrackingValueSubject.sink { (isHeadTrackingEnabled) in
            self.setCursorViewHidden(!isHeadTrackingEnabled, animated: true)
            if isHeadTrackingEnabled {
                self.touchGazeDisableBeganDate = .distantPast
            }
        }.store(in: &disposables)
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        commonInit()
    }
    
    override func addSubview(_ view: UIView) {
        super.addSubview(view)
        self.bringSubviewToFront(cursorView)
        self.bringSubviewToFront(warningView)
        self.bringSubviewToFront(phraseSavedView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func initializeWarningView() {
           warningView = UINib(nibName: "WarningView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
           self.addSubview(warningView)
           let width = UIScreen.main.traitCollection.horizontalSizeClass == .compact ? 350 : 425
           warningView.translatesAutoresizingMaskIntoConstraints = false
        
           NSLayoutConstraint.activate([
               warningView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
               warningView.widthAnchor.constraint(equalToConstant: CGFloat(width)),
               warningView.heightAnchor.constraint(equalToConstant: 57),
               warningView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
           ])
       }
    
    private func initializePhraseSaveView() {
        phraseSavedView = UINib(nibName: "PhraseSavedView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
        self.addSubview(phraseSavedView)
        let width = UIScreen.main.traitCollection.horizontalSizeClass == .compact ? 300 : 475
        phraseSavedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            phraseSavedView.widthAnchor.constraint(equalToConstant: CGFloat(width)),
            phraseSavedView.heightAnchor.constraint(equalToConstant: 96),
            phraseSavedView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            phraseSavedView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func commonInit() {
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
        UIView.animate(withDuration: 1.5, animations: {
            self.phraseSavedView.alpha = CGFloat(1.0)
        })
        UIView.animate(withDuration: 1.5, animations: {
            self.phraseSavedView.alpha = CGFloat(0)
        })
    }
    
    private func handleWarning(shouldDisplay: Bool) {
        let alphaValue = shouldDisplay ? 1.0 : 0.0
        UIView.animate(withDuration: 0.5, animations: {
            self.warningView.alpha = CGFloat(alphaValue)
        })
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
        touchGazeDisableBeganDate = Date()
    }

    private func setCursorViewHidden(_ isCursorHidden: Bool, animated: Bool) {
        func actions() {
            for cursor in cursorView.cursorViews {
                cursor.alpha = isCursorHidden ? 0.0 : 1.0
                cursor.transform = isCursorHidden ? CGAffineTransform(scaleX: 0.1, y: 0.1) : .identity
            }
        }

        if animated {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.4,
                           options: .beginFromCurrentState,
                           animations: actions,
                           completion: nil)
        } else {
            actions()
        }
    }

    func animateCursorSelection() {

        func performSelectionAnimation(_ cursor: CursorView) {
            let duration: TimeInterval = 0.6
            let relativeDownDuration = duration * 0.5
            let relativeUpDuration = (1.0 - relativeDownDuration) * 0.5
            let relativeSettleDuration = 1.0 - relativeUpDuration
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.beginFromCurrentState], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: relativeDownDuration) {
                    cursor.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    cursor.shadowAmount = 0.8
                }
                UIView.addKeyframe(withRelativeStartTime: 1.0 - relativeSettleDuration - relativeUpDuration, relativeDuration: relativeUpDuration) {
                    cursor.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    cursor.shadowAmount = 1.0
                }
                UIView.addKeyframe(withRelativeStartTime: 1.0 - relativeSettleDuration, relativeDuration: relativeSettleDuration) {
                    cursor.transform = .identity
                }
            }, completion: nil)
        }

        for cursor in cursorView.cursorViews {
            performSelectionAnimation(cursor)
        }
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
                    setCursorViewHidden(true, animated: true)
                }
            super.sendEvent(originalEvent)
            return
        }

        if let gazeDisabledStart = touchGazeDisableBeganDate {
            if Date().timeIntervalSince(gazeDisabledStart) >= touchGazeDisableDuration {
                setCursorViewHidden(false, animated: true)
                touchGazeDisableBeganDate = nil
            } else {
                // Waiting for touch timeout to allow events to propagate
                return
            }
        }

        lastGaze = event.allGazes?.first

        // If something has registered as the cursor view, let it know
        // there was a state change
        cursorView.gazeMoved(gaze, with: event)

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
