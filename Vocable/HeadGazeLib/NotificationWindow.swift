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

class NotificationWindow: UIWindow {
    
    private var cancellables = Set<AnyCancellable>()
    static var passThroughTag = 42
    
    private static var _shared: NotificationWindow?
    
    static var shared: NotificationWindow {
        if _shared == nil {
            let shared = NotificationWindow(frame: UIScreen.main.bounds)
            shared.backgroundColor = .clear
            shared.translatesAutoresizingMaskIntoConstraints = false
            shared.rootViewController = ToastContainerViewController()
            _shared = shared
        }
        return _shared!
    }
    
    var toastContainer: ToastContainerViewController {
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
        
    }
    
    func handleWarning(shouldDisplay: Bool) {
        toastContainer.handleWarning(shouldDisplay: shouldDisplay)
    }
    
    func handlePhraseSaved(toastLabelText: String) {
        toastContainer.handlePhraseSaved(toastLabelText: toastLabelText)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let hitView = super.hitTest(point, with: event)
        
        if NotificationWindow.passThroughTag == hitView?.tag {
                return nil
            }
        return hitView
    }
    
}
