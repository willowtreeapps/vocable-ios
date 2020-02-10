import UIKit

class UIHeadGaze: UITouch {

    let selectionHoldDuration: TimeInterval = 1

    private weak var _window: UIWindow?
    private let _receiver: UIView
    private let _position: CGPoint //NDC coordinates [0,1] x [0,1], origin is lower left corner of the screen
    private let _previousPosition: CGPoint //NDC coordinates [0,1] x [0,1], origin is lower left corner of the screen

    /**
     The time when the event occurred
     */
    private var _timestamp: TimeInterval

    /**
     Returns the time when the event occurred
     */
    public var timeStamp: TimeInterval {
        return _timestamp
    }

    override public var description: String {
            return """
        UIHeadGazeEvent: position in NDC: \(_position), previous position in NDC \(_previousPosition), receiver: \(_receiver), window: \(String(describing: _window))
        """
    }

    convenience init(position: CGPoint, view uiview: UIView, win window: UIWindow? = nil) {
        self.init(curPosition: position, prevPosition: position, view: uiview, win: window)
    }

    init(curPosition: CGPoint, prevPosition: CGPoint, view uiview: UIView, win window: UIWindow? = nil) {
        self._window = window
        self._receiver = uiview
        self._position = curPosition
        self._previousPosition = prevPosition
        self._timestamp = Date().timeIntervalSince1970
    }

    /**
     @Returns: 1. Position of gaze projected on the screen measured in the coordinates of given view
              2. or position in NDC coordinates if view is nil
    */
    override func location(in view: UIView?) -> CGPoint {
        guard let point = transformNDCPoint(_position, in: view) else {
            return _position
        }
        return point
    }

    /**
     @Returns: 1. Previous position of gaze projected on the screen measured in the coordinates of given view
               2. or position in NDC coordinates if view is nil
     */
    override func previousLocation(in view: UIView?) -> CGPoint {
        guard let point = transformNDCPoint(_previousPosition, in: view) else {
            return _previousPosition
        }
        return point
    }

    private func transformNDCPoint(_ point: CGPoint, in view: UIView?) -> CGPoint? {
        guard let view = view, let window = view.window ?? (view as? UIWindow) else {
            return nil
        }
        func clamp(_ value: CGFloat) -> CGFloat {
            return max(min(value, 1.0), 0.0)
        }
        
        // Inset the window by one pixel to ensure the point is inside the window's bounds
        // See: https://developer.apple.com/documentation/coregraphics/cgrect/1456316-contains
        let windowWidth: CGFloat = max(window.frame.width - 1, 0)
        let windowHeight: CGFloat = max(window.frame.height - 1, 0)
        
        let winPos = CGPoint(x: clamp(point.x+0.5) * windowWidth, y: clamp(1.0-(point.y+0.5)) * windowHeight)
        let viewPos = view.convert(winPos, from: window)
        return viewPos
    }
}
