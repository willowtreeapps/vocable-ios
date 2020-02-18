//
//  HotCornerOverlayViewController.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final private class HotCornerExpandingUIControl: UIButton {

    private var gazeBeginDate: Date?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .defaultCellBackgroundColor
        titleLabel?.textColor = .defaultTextColor
    }

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        backgroundColor = .cellSelectionColor
        titleLabel?.textColor = .selectedTextColor
        gazeBeginDate = Date()
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard let beginDate = gazeBeginDate else { return }
        let elapsedTime = Date().timeIntervalSince(beginDate)
        if elapsedTime >= gaze.selectionHoldDuration {
            (window as? HeadGazeWindow)?.animateCursorSelection()
            sendActions(for: .primaryActionTriggered)
            gazeBeginDate = nil
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        backgroundColor = .defaultCellBackgroundColor
        titleLabel?.textColor = .defaultTextColor
        gazeBeginDate = nil
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 88, height: 88)
    }
}

class HotCornerOverlayView: UIView {

    var isInterceptingAllGazeEvents: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let existing = super.hitTest(point, with: event)
        if isInterceptingAllGazeEvents {
            return existing ?? self
        } else if existing == self {
            return nil
        }
        return existing
    }

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        guard let existing = super.gazeableHitTest(point, with: event) else {
            if isInterceptingAllGazeEvents {
                return self
            }
            return nil
        }
        if existing == self && !isInterceptingAllGazeEvents {
            return nil
        }
        return existing
    }
}

final class HotCornerOverlayViewController: UIViewController {

    @IBOutlet private var settingsContainerView: UIView!
    
    private let pauseButton = HotCornerExpandingUIControl()
    private let settingsButton = HotCornerExpandingUIControl()

    private var overlayView: HotCornerOverlayView {
        return self.view as! HotCornerOverlayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set pause hot corner
        self.view.addSubview(pauseButton)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pauseButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pauseButton.addTarget(self, action: #selector(pauseTracking(_:)), for: .primaryActionTriggered)
        pauseButton.titleLabel?.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        setUIControlImage(uiControl: pauseButton, systemName: "pause.fill")
        
        // set settings hot corner
        self.view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        settingsButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        settingsButton.addTarget(self, action: #selector(goToSettings(_:)), for: .primaryActionTriggered)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        setUIControlImage(uiControl: settingsButton, systemName: "gear")
        
    }
    
    private func setUIControlImage(uiControl: HotCornerExpandingUIControl, systemName: String) {
        let systemPauseImage = NSTextAttachment(image: UIImage(systemName: systemName)!)
        uiControl.setAttributedTitle(NSMutableAttributedString(attachment: systemPauseImage), for: .normal)
    }

    @objc private func pauseTracking(_ sender: Any?) {
        overlayView.isInterceptingAllGazeEvents.toggle()
        if overlayView.isInterceptingAllGazeEvents {
            setUIControlImage(uiControl: pauseButton, systemName: "play.fill")
            overlayView.backgroundColor = UIColor.collectionViewBackgroundColor.withAlphaComponent(0.9)
        } else {
            setUIControlImage(uiControl: pauseButton, systemName: "pause.fill")
            overlayView.backgroundColor = UIColor.clear
        }
    }
    
    @objc private func goToSettings(_ sender: Any?) {
        settingsContainerView.isHidden.toggle()
        pauseButton.isHidden.toggle()
        
        if settingsContainerView.isHidden {
            setUIControlImage(uiControl: settingsButton, systemName: "gear")
        } else {
            setUIControlImage(uiControl: settingsButton, systemName: "xmark.circle")
        }
    }
}
