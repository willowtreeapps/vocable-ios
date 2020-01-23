//
//  GraphView.swift
//  Pulse
//
//  Created by Dawid Cieslak on 23/02/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// View with gradient background
class GradientView: UIView {
    
    /// Static values for UI components
    struct LayoutConstants {
        struct Shadow {
            static let Color: CGColor = UIColor.black.cgColor
            static let Offset: CGSize = CGSize(width: 2, height: 5)
            static let Opacity: Float = 0.2
        }
        static let CornerRadius: CGFloat = 4.5
    }
    
    /// Layer displaying background gradient
    private let backgroundLayer: CAGradientLayer = CAGradientLayer()
    
    /// Init with gradient colors
    ///
    /// - Parameter backgroundColors: Colors of gradinet to be applied
    init(backgroundColors: [UIColor]) {
        super.init(frame: .zero)
        layer.addSublayer(backgroundLayer)
        
        backgroundColor = .clear
        backgroundLayer.applyGradientColors(backgroundColors)
        backgroundLayer.cornerRadius = LayoutConstants.CornerRadius
        backgroundLayer.masksToBounds = true
        
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = LayoutConstants.Shadow.Color
        layer.shadowOffset = LayoutConstants.Shadow.Offset
        layer.shadowOpacity = LayoutConstants.Shadow.Opacity
     }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
    }
}
