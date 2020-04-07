//
//  NotificationWindow.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import ARKit
import Combine

class ToastWindow: UIWindow {
    
    private static var _shared: ToastWindow?
    
    static var shared: ToastWindow {
        if _shared == nil {
            let shared = ToastWindow(frame: UIScreen.main.bounds)
            shared.backgroundColor = .clear
            shared.translatesAutoresizingMaskIntoConstraints = false
            shared.rootViewController = ToastContainerViewController()
            _shared = shared
        }
        return _shared!
    }
    
    var toastContainerViewController: ToastContainerViewController {
        return self.rootViewController as! ToastContainerViewController
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.isUserInteractionEnabled = false
    }
    
    func updateHeadTrackingWarningToast() {
        if !UIApplication.shared.isGazeTrackingActive && !toastContainerViewController.isToastWarningVisible {
            presentPersistantWarning(with: NSLocalizedString("Please move closer to the device.", comment: "Warning title when head tracking is lost."))
        }
    }
    
    func presentPersistantWarning(with title: String) {
        toastContainerViewController.handleWarning(with: title, shouldDisplay: true)
    }
    
    func dismissPersistantWarning() {
        toastContainerViewController.handleWarning(with: nil, shouldDisplay: false)
    }
    
    func presentEphemeralToast(withTitle: String) {
        toastContainerViewController.handlePhraseSaved(toastLabelText: withTitle)
    }
    
}
