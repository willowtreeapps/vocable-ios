//
//  UIColor+AppExtensions.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/16/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit


extension UIColor {
    convenience init(rgbRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    static let animatingColor = UIColor(rgbRed: 126, green: 116, blue: 227, alpha: 0.2)
    static let appBackgroundColor = UIColor(rgbRed: 248, green: 248, blue: 248, alpha: 1.0)
    
    static let hotCornerColor = UIColor(rgbRed: 113, green: 101, blue: 225, alpha: 0.9)
    static let textPredictiveColor = UIColor.hotCornerColor.withAlphaComponent(1.0)
    static let mainHoverBorderColor = UIColor.textPredictiveColor
    
    static let mainWidgetBorderColor = UIColor(rgbRed: 175, green: 175, blue: 175, alpha: 1.0)
    static let mainTextColor = UIColor(rgbRed: 56, green: 56, blue: 56, alpha: 1.0)
    static let mainBackButtonColor = UIColor(rgbRed: 232, green: 232, blue: 232, alpha: 1.0)
    
    static let clearButtonHoverColor = UIColor(rgbRed: 255, green: 141, blue: 141, alpha: 1.0)
    static let backspaceButtonHoverColor = UIColor(rgbRed: 255, green: 197, blue: 197, alpha: 1.0)
    static let speakBoxHoverColor = UIColor(rgbRed: 194, green: 255, blue: 215, alpha: 1.0)
    
    static let clearButtonHoverBorderColor = UIColor(rgbRed: 250, green: 49, blue: 49, alpha: 1.0)
    static let backspaceButtonHoverBorderColor = UIColor(rgbRed: 254, green: 126, blue: 126, alpha: 1.0)
    static let speakBoxHoverBorderColor = UIColor(rgbRed: 49, green: 208, blue: 103, alpha: 1.0)
    
    static let backButtonBackgroundColor = UIColor(rgbRed: 232, green: 232, blue: 232, alpha: 1.0)
}
