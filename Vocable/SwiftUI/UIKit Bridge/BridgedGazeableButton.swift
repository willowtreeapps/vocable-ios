//
//  BridgedGazeableButton.swift
//  Vocable
//
//  Created by Robert Moyer on 4/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import UIKit

class BridgedGazeableButton: UIButton {
    var minimumGazeDuration: TimeInterval = 2

    private var gazeStartDate: Date?

    var stateSubject: CurrentValueSubject<ButtonState, Never> = .init(.normal)

    override var canReceiveGaze: Bool { true }

    override var intrinsicContentSize: CGSize {
        subviews.first?.intrinsicContentSize ??
            CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    // MARK: State Updates

    override var isHighlighted: Bool {
        didSet {
            let currentState = stateSubject.value
            let newState = isHighlighted ?
                currentState.union(.highlighted) :
                currentState.subtracting(.highlighted)
            stateSubject.send(newState)
        }
    }

    override var isSelected: Bool {
        didSet {
            let currentState = stateSubject.value
            let newState = isSelected ?
                currentState.union(.selected) :
                currentState.subtracting(.selected)
            stateSubject.send(newState)
        }
    }

    // MARK: Gaze Overrides

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard isEnabled else { return }

        gazeStartDate = Date()
        isHighlighted = true
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard isEnabled else { return }
        guard let gazeStartDate = gazeStartDate else { return }

        let elapsedTime = Date().timeIntervalSince(gazeStartDate)

        if elapsedTime >= minimumGazeDuration {
            isSelected = true
            sendActions(for: .primaryActionTriggered)
            self.gazeStartDate = nil
            (window as? HeadGazeWindow)?.animateCursorSelection()
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard isEnabled else { return }

        resetState()
    }

    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard isEnabled else { return }

        resetState()
    }

    private func resetState() {
        gazeStartDate = nil
        isSelected = false
        isHighlighted = false
    }
}
