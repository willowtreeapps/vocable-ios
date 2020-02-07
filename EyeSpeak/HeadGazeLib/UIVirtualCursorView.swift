import Foundation
import UIKit
import SpriteKit

class UIVirtualCursorView: UIView {

    var cursorView = CursorView()

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
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    private func initializeHeadGazeView() {

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
        cursorView.tintColor = isNowActive ? .cyan : UIColor.orange.withAlphaComponent(0.5)
    }

    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        updateForCurrentGazeActivityStatus()
    }

    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        updateForCurrentGazeActivityStatus()
    }
    
    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        let position = gaze.location(in: self)
        UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: {
            self.cursorView.center = position
        }, completion: nil)
    }
}
