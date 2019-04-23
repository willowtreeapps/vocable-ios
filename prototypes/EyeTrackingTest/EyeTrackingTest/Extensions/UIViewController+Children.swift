//
//  UIViewController+Children.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/23/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(to parent: UIViewController, in containerView: UIView?) {
        let parentView = containerView ?? parent.view
        self.willMove(toParent: parent)
        self.view.frame = parentView?.bounds ?? .zero
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView?.addSubview(self.view)
        parent.addChild(self)
        self.didMove(toParent: parent)
    }
    
    func show(in parentView: UIView?) {
        self.view.frame = parentView?.bounds ?? .zero
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView?.addSubview(self.view)
    }
    
    func hideFromParentViewController() {
        self.view.removeFromSuperview()
    }
    
    func remove(from parent: UIViewController) {
        self.willMove(toParent: nil)
        self.hideFromParentViewController()
        self.didMove(toParent: nil)
    }
}
