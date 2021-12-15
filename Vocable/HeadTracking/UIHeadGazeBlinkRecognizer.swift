import Foundation
import UIKit.UIGestureRecognizerSubclass

class UIHeadGazeBlinkRecognizer: UIGestureRecognizer {

    func blinkBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        // No-op
    }

    func blinkEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        // No-op
    }

    func blinkCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        // No-op
    }

}
