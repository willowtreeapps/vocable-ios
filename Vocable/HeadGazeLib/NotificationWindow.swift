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
    weak var cursorView: UIVirtualCursorView?
    
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
        
        AppConfig.$isHeadTrackingEnabled.sink { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.installCursorViewIfNeeded()
            } else {
                self.cursorView?.removeFromSuperview()
                self.handleWarning(shouldDisplay: false)
            }
        }.store(in: &cancellables)
    }
    
    private func installCursorViewIfNeeded() {
        guard cursorView?.superview == nil else { return }

        let cursorView = UIVirtualCursorView()
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cursorView)

        NSLayoutConstraint.activate([
            cursorView.topAnchor.constraint(equalTo: topAnchor),
            cursorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cursorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cursorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.cursorView = cursorView
    }
    
    func handleWarning(shouldDisplay: Bool) {
        toastContainer.handleWarning(shouldDisplay: shouldDisplay)
    }
    
    func handlePhraseSaved(toastLabelText: String) {
        toastContainer.handlePhraseSaved(toastLabelText: toastLabelText)
    }
}
