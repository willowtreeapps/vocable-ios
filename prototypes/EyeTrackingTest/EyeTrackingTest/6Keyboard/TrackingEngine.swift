//
//  TrackingEngine.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/4/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit


class TrackingEngine {

    func updateWithTrackedPoint(_ point: CGPoint) {

        var foundView: Bool = false
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
            }
        }

        if foundView == false {
            self.currentTrackedView?.cancelAnimation()
            self.trackingTimer?.invalidate()
        }

    }

    func registerView(_ view: TrackingView) {
        self.trackedViews.append(view)
    }

    private var trackedViews: [TrackingView] = []

    private func startNewTrackingTimer(for view: TrackingView) {
        self.currentTrackedView?.cancelAnimation()

        let gazeDuration = 1.0

        view.animateGaze(withDuration: gazeDuration)
        self.trackingTimer?.invalidate()
        self.trackingTimer = Timer.scheduledTimer(withTimeInterval: gazeDuration, repeats: false, block: { (_) in
            view.onGaze?()
        })
        
        self.currentTrackedView = view
    }

    // MARK: - Tracking time on view

    private var trackingTimer: Timer?
    private var currentTrackedView: TrackingView?

}
