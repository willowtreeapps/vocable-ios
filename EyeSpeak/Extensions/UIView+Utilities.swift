//
//  UIView+Utilities.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/16/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension UIView {
    var tallestSide: CGFloat {
        return max(self.bounds.width, self.bounds.height)
    }
    
    var relativeCenterPoint: CGPoint {
        return CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
    }
}
