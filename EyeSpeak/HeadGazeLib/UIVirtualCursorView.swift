import Foundation
import UIKit
import SpriteKit

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
        if let window = newWindow as? HeadGazeWindow {
            window.cursorView = self
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
}
