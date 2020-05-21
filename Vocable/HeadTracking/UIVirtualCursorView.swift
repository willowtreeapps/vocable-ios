import Foundation
import UIKit
import SpriteKit

class UIVirtualCursorViewController: UIViewController {

    private(set) var virtualCursorView = UIVirtualCursorView(frame: .zero)

    override func loadView() {
        self.view = self.virtualCursorView
    }
}

class UIVirtualCursorView: UIView {

    private var cursorView = CursorView()
    private var debugCursorView = CursorView()
    var cursorViews: [CursorView] {
        return [cursorView, debugCursorView]
    }

    private var cursorPosition: CGPoint = .zero
    private var debugCursorPosition: CGPoint = .zero
    var isDebugCursorHidden: Bool {
        get {
            return debugCursorView.isHidden
        }
        set {
            debugCursorView.isHidden = newValue
        }
    }

    private var displayLink: CADisplayLink?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeHeadGazeView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeHeadGazeView()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire(_:)))
            displayLink?.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
            displayLink?.add(to: .current, forMode: .common)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    private func initializeHeadGazeView() {

        addSubview(debugCursorView)
        debugCursorView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        debugCursorView.sizeToFit()
        debugCursorView.isHidden = true

        addSubview(cursorView)
        cursorView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        cursorView.sizeToFit()
        
        backgroundColor = .clear
        updateForCurrentGazeActivityStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
    }

    private func updateForCurrentGazeActivityStatus() {
        let isNowActive = UIApplication.shared.isGazeTrackingActive
        cursorView.tintColor = isNowActive ? .cellBorderHighlightColor : UIColor.orange.withAlphaComponent(0.5)
        debugCursorView.tintColor = isNowActive ? UIColor.red.withAlphaComponent(0.6) : UIColor.red.withAlphaComponent(0.1)
    }

    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        updateForCurrentGazeActivityStatus()
    }

    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        updateForCurrentGazeActivityStatus()
    }
    
    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        let position = gaze.location(in: self)
        cursorPosition = position
    }

    func debugCursorMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        let position = gaze.location(in: self)
        debugCursorPosition = position
    }

    @objc
    private func displayLinkDidFire(_ sender: CADisplayLink) {
        self.cursorView.center = cursorPosition
        self.debugCursorView.center = debugCursorPosition
    }

    func setCursorViewsHidden(_ isCursorHidden: Bool, animated: Bool) {

        func actions() {
            for cursor in cursorViews {
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

        for cursor in cursorViews {
            performSelectionAnimation(cursor)
        }
    }
}
