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
    static let alertBackgroundColor = UIColor(named: "AlertBackground")!

    static let grayDivider = UIColor(named: "GrayDivider")!
}
