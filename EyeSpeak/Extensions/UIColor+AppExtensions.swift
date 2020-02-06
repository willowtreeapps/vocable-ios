//
//  UIColor+AppExtensions.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/16/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: New Branded Colors
    
    static let primaryColor = UIColor(named: "Primary")!
    
    static let defaultTextColor = UIColor(named: "DefaultFontColor")!
    static var selectedTextColor: UIColor {
        return collectionViewBackgroundColor
    }

    static let collectionViewBackgroundColor = UIColor(named: "Background")!
    static let defaultCellBackgroundColor = UIColor(named: "DefaultCellBackground")!
    static let categoryBackgroundColor = UIColor(named: "CategoryBackground")!
    
    static let cellSelectionColor = UIColor(named: "Selection")!
    static let cellBorderHighlightColor = UIColor(named: "BorderHighlight")!
    
    // MARK: Deprecated Colors
    
    convenience init(rgbRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    static let appBackgroundColor = UIColor(rgbRed: 255, green: 255, blue: 255, alpha: 1.0)
    static let hotCornerColor = UIColor(rgbRed: 115, green: 0, blue: 225, alpha: 0.9)
        
    static let mainWidgetBorderColor = UIColor(rgbRed: 175, green: 175, blue: 175, alpha: 1.0)
    static let mainTextColor = UIColor(rgbRed: 56, green: 56, blue: 56, alpha: 1.0)
    static let mainBackButtonColor = UIColor(rgbRed: 232, green: 232, blue: 232, alpha: 1.0)
    
    static let textBoxFill = UIColor(rgbRed: 255, green: 255, blue: 255, alpha: 1.0)
    static let textBoxBloom = UIColor(rgbRed: 190, green: 255, blue: 212, alpha: 1.0)
    static let textBoxBorder = UIColor(rgbRed: 175, green: 175, blue: 175, alpha: 1.0)
    static let textBoxBorderHover = UIColor(rgbRed: 88, green: 228, blue: 135, alpha: 1.0)
    
    static let backspaceFill = UIColor(rgbRed: 254, green: 225, blue: 190, alpha: 1.0)
    static let backspaceBloom = UIColor(rgbRed: 255, green: 205, blue: 144, alpha: 1.0)
    static let backspaceBorderHover = UIColor(rgbRed: 255, green: 175, blue: 78, alpha: 1.0)
    
    static let clearButtonFill = UIColor(rgbRed: 254, green: 190, blue: 190, alpha: 1.0)
    static let clearButtonBloom = UIColor(rgbRed: 255, green: 145, blue: 145, alpha: 1.0)
    static let clearButtonBorderHover = UIColor(rgbRed: 255, green: 77, blue: 77, alpha: 1.0)
    
    static let predictionTextFill = UIColor(rgbRed: 227, green: 237, blue: 255, alpha: 1.0)
    static let predictionTextBloom = UIColor(rgbRed: 190, green: 213, blue: 255, alpha: 1.0)
    static let predictionTextBorderHover = UIColor(rgbRed: 77, green: 138, blue: 255, alpha: 1.0)
    
    static let keyboardFill = UIColor(rgbRed: 240, green: 227, blue: 255, alpha: 1.0)
    static let keyboardBloom = UIColor(rgbRed: 220, green: 191, blue: 255, alpha: 1.0)
    static let keyboardBorderHover = UIColor(rgbRed: 158, green: 78, blue: 255, alpha: 1.0)
    
    static let backKeyboardFill = UIColor(rgbRed: 232, green: 232, blue: 232, alpha: 1.0)
    static let backKeyboardBloom = UIColor(rgbRed: 202, green: 202, blue: 202, alpha: 1.0)
    static let backKeyboardBorderHover = UIColor(rgbRed: 56, green: 56, blue: 56, alpha: 1.0)
    
}
