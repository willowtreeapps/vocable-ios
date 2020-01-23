//
//  TunningWindow.swift
//  Pulse
//
//  Created by Dawid Cieslak on 21/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// UIWindow passing through all touches that doesn't belong to it's root View Controller
class TunningWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if let _ = rootViewController?.view.hitTest(point, with: event){
            return view
        } else {
            return nil
        }
    }
}
