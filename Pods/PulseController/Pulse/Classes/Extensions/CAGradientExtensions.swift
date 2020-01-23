//
//  CAGradientExtensions.swift
//  Pulse
//
//  Created by Dawid Cieslak on 16/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    /// Applies group of given colors evenly as gradient
    ///
    /// - Parameter gradientColors: Colors to be applied as gradient, starting from top to the bottom
    func applyGradientColors(_ gradientColors: [UIColor]) {
        
        // Change type of provided colors
        var backgroundGradientColors: [CGColor] = [CGColor]()
        for color in gradientColors {
            backgroundGradientColors.append(color.cgColor)
        }
        
        // Calculate locations of colors
        var backgroundColorLocations: [NSNumber] = [NSNumber]()
        for i in (0..<gradientColors.count) {
            let val: Double = Double(i) * (1.0/Double(gradientColors.count-1))
            backgroundColorLocations.append(NSNumber(value: val))
        }
        
        colors = backgroundGradientColors
        locations = backgroundColorLocations
    }
}


