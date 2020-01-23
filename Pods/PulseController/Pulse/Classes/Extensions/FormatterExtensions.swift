//
//  FormatterExtensions.swift
//  Pulse
//
//  Created by Dawid Cieslak on 15/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import Foundation

extension Formatter {
    
    /// Creates number formatter with exact fraction digits
    ///
    /// - Parameter fractionDigits: Number of fraction digits
    /// - Returns: Number formatter with decimal format and specified number of fraction digits
    static func decimalFormat(fractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.numberStyle = .decimal
        return formatter
    }
}
