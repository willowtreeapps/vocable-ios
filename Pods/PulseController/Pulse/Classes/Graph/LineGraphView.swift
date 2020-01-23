//
//  GraphView.swift
//  Pulse
//
//  Created by Dawid Cieslak on 14/02/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// Graph displaying multiple line charts
class LineGraphView: UIView {
    
    /// All items displayed on graph
     private let items: [LineGraphItem]
    
    // Background gradinet layer
    private let backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 10.0
        return layer
    }()
    
    /// Shows gradinet for graph
    private var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.cornerRadius = 10
        layer.masksToBounds = true
        return layer
    }()
    
    required init(items: [LineGraphItem], backgroundColors: [UIColor]) {
        self.items = items
        self.gradientLayer.applyGradientColors(backgroundColors)
        super.init(frame: .zero)

        layer.addSublayer(backgroundLayer)
        layer.addSublayer(gradientLayer)
        
        for item in items {
            layer.insertSublayer(item, at: 1)
        }
        
        backgroundLayer.shadowColor = UIColor.black.cgColor
        backgroundLayer.shadowOffset = CGSize(width: 4, height: 4)
        backgroundLayer.shadowRadius = 10
        backgroundLayer.shadowOpacity = 0.3
    }
 
    /// Updates current position of each item
    func update() {
        for item in items {
            item.update()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
      
    }
    override func layoutSubviews() {
        super.layoutSubviews()
     
        backgroundLayer.frame = bounds
        
        // TODO: Move constant values
        gradientLayer.frame = bounds.insetBy(dx: 10, dy: 10)
        
        let boundNoCorners = CGRect(x: 10,y: 10,
                                         width: bounds.width,
                                         height: bounds.height - 10*2)
        for item in items {
            item.frame = boundNoCorners
        }
    }
}
