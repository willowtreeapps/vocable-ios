//
//  TrackingEngine.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/4/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

class TrackingEngine {
    
    var parent: TrackingEngine?
    
    var isUnlocked: Bool = true {
        willSet {
            if self.isUnlocked != newValue {
                self.trackedViews.forEach { view in
                    view.isTrackingEnabled = newValue
                }
            }
        }
    }
    
    func updateWithTrackedPoint(_ point: CGPoint) -> Bool {

        if self.parent?.updateWithTrackedPoint(point) ?? false {
            return true
        }
        
        var foundView = false
        for view in self.trackedViews {

            let positionInView = view.convert(point, from: nil)
            if nil != view.hitTest(positionInView, with: nil) {

                foundView = true

                if let currentView = self.currentTrackedView,
                    view == currentView {

                    if self.trackingTimer?.isValid == false {
                        self.startNewTrackingTimer(for: view)
                    }

                } else {
                    self.startNewTrackingTimer(for: view)
                }
                return true
            }
        }

        if !foundView {
            self.currentTrackedView?.cancelAnimation()
            self.trackingTimer?.invalidate()
        }
        return foundView

    }

    func registerView(_ view: TrackingView) {
        self.trackedViews.append(view)
    }
    
    func applyToEach(_ completion: (TrackingView) -> Void) {
        for trackedView in self.trackedViews {
            completion(trackedView)
        }
    }

    private var trackedViews: [TrackingView] = []

    private func startNewTrackingTimer(for view: TrackingView) {
        self.currentTrackedView?.cancelAnimation()
        if view.isTrackingEnabled {
            view.animateGaze()
            self.trackingTimer?.invalidate()
            self.trackingTimer = Timer.scheduledTimer(withTimeInterval: view.animationSpeed, repeats: false, block: { (_) in
                view.onGaze?(view.id)
            })
            self.currentTrackedView = view
        }
    }

    // MARK: - Tracking time on view

    private var trackingTimer: Timer?
    private var currentTrackedView: TrackingView?

}
