//
//  GraphItem.swift
//  Pulse
//
//  Created by Dawid Cieslak on 22/02/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//

import UIKit

/// Single line chart displaying 
class LineGraphItem: CALayer {
    
    /// Array of most recent values
    var values: Queue<CGFloat>
    
    /// Position of first value in relation to full width of graph
    let headValueOffsetFactor: CGFloat
    
    /// Minimum value
    let minimumValue: CGFloat
    
    /// Maximum value
    let maximumValue: CGFloat
    
    private struct Constants {
        
        /// Maximum number of stored values
        ///
        /// @discussion: Affects length of graph's "tail"
        static let ValueMemorySize: Int = 350
    }
    
    /// Static values for UI components
    private struct LayoutConstants {
        /// Background color of shape
        static let BackgroundColor: CGColor = UIColor.clear.cgColor
        
        /// Fill color for shape
        static let FillColor: CGColor = UIColor.clear.cgColor
        
        /// Line width
        static let LineWidth: CGFloat = 1.5
        
        /// Space between presented values
        static let ValueSpacing: CGFloat = 1
    }
    
    /// Draws line representing arrat of most recent values
    let strokeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = LayoutConstants.BackgroundColor
        layer.lineWidth = LayoutConstants.LineWidth
        layer.fillColor = LayoutConstants.FillColor
        return layer
    }()

    /// Inits with configuration
    ///
    /// - Parameters:
    ///   - initialValue: Default value for all initial values displayed on graph
    ///   - strokeColor: Color of line stroke
    /// TODO: Description
    required init(initialValue: CGFloat, strokeColor: UIColor, headValueOffsetFactor: CGFloat, minimumValue: CGFloat, maximumValue: CGFloat) {
        self.values = Queue(count: Constants.ValueMemorySize, initialValue: initialValue)
        self.headValueOffsetFactor = headValueOffsetFactor
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        super.init()
        backgroundColor = LayoutConstants.BackgroundColor
        strokeLayer.strokeColor = strokeColor.cgColor
     
        addSublayer(strokeLayer)
     }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        strokeLayer.frame = bounds
    }
    
    /// Path for graph shape calculated starting from recent values
    private var valuesPath: UIBezierPath {
        
        let allValues: [CGFloat] = values.allValuesReversed()
        
        let shapePath = UIBezierPath()
        var currentXPosition: CGFloat = bounds.width * headValueOffsetFactor
        var currentValueIndex: Int = 0
        
        while currentXPosition > 0 && currentValueIndex < allValues.count {
            // Reverse to start with head value
            let currentValue: CGFloat = allValues[currentValueIndex]
            
            // current value changed to range <0, 1>
            let normalizedValue = (currentValue - minimumValue) / (maximumValue - minimumValue)
            
            // Make sure value is in provided range
            let limitedValue: CGFloat = min(max(normalizedValue, minimumValue), maximumValue)
            
            let currentPoint = CGPoint(x: currentXPosition, y: bounds.height - limitedValue * bounds.height)
            
            if shapePath.isEmpty {
                shapePath.move(to: currentPoint)
            } else {
                shapePath.addLine(to: currentPoint)
            }
            currentXPosition -= LayoutConstants.ValueSpacing
            currentValueIndex += 1
        }
 
        return shapePath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Append new value to queue
    ///
    /// - Parameter value: Value to be added at the end of queue
    func addValue(_ value: CGFloat) {
        values.append(value: value)
    }

    /// Updates graph shape
    func update() {
         strokeLayer.path = valuesPath.cgPath
    }
}

