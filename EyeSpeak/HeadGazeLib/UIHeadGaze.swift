import UIKit

class UIHeadGaze: UITouch {

    private weak var _window: UIWindow?
    private let _receiver: UIView
    private let _position: CGPoint //NDC coordinates [0,1] x [0,1], origin is lower left corner of the screen
    private let _previousPosition: CGPoint //NDC coordinates [0,1] x [0,1], origin is lower left corner of the screen
    let isLeftEyeBlinking: Bool
    let isRightEyeBlinking: Bool

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

    convenience init(position: CGPoint, view uiview: UIView, win window: UIWindow? = nil, isLeftEyeBlinking: Bool, isRightEyeBlinking: Bool) {
        self.init(curPosition: position, prevPosition: position, view: uiview, win: window, isLeftEyeBlinking: isLeftEyeBlinking, isRightEyeBlinking: isRightEyeBlinking)
    }

    init(curPosition: CGPoint, prevPosition: CGPoint, view uiview: UIView, win window: UIWindow? = nil, isLeftEyeBlinking: Bool, isRightEyeBlinking: Bool) {
        self._window = window
        self._receiver = uiview
        self._position = curPosition
        self._previousPosition = prevPosition
        self._timestamp = Date().timeIntervalSince1970
        self.isLeftEyeBlinking = isLeftEyeBlinking
        self.isRightEyeBlinking = isRightEyeBlinking
    }

    /**
     @Returns: 1. Position of gaze projected on the screen measured in the coordinates of given view
              2. or position in NDC coordinates if view is nil
    */
    override func location(in view: UIView?) -> CGPoint {
        guard let view = view, let window = view.window ?? view as? UIWindow else {
            return _position
        }
        let winPos = CGPoint(x: (self._position.x+0.5) * window.frame.width, y: (1.0-(self._position.y+0.5)) * window.frame.height)
        let viewPos = view.convert(winPos, from: window)
        return viewPos
    }

    /**
     @Returns: 1. Previous position of gaze projected on the screen measured in the coordinates of given view
               2. or position in NDC coordinates if view is nil
     */
    override func previousLocation(in view: UIView?) -> CGPoint {
        guard let view = view, let window = view.window else {
            return _previousPosition
        }
        let winPos = CGPoint(x: (self._previousPosition.x+0.5) * window.frame.width, y: (1.0-(self._previousPosition.y+0.5)) * window.frame.height)
        let viewPos = view.convert(winPos, from: window)
        return viewPos
    }
}
