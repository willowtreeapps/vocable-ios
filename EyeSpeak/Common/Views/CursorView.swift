//
//  CursorView.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/25/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

final class CursorView: UIView {

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }

    // Scales the magnitude of the shadow to make it animatable
    // by a single property. For example, one may bind this property
    // to a UIScrollView offset or UISlider to make a given shadow dynamically
    // "lift" a view off of its background.
    var shadowAmount: CGFloat = 1.0 {
        didSet {

            // Clamp it to the interval [0, 1]
            shadowAmount = max(min(shadowAmount, 1.0), 0.0)
            self.updateShadowProperties()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateShapeLayer()
        sizeToFit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateShapeLayer()
        sizeToFit()
    }

    override var frame: CGRect {
        didSet {
            if frame.size != oldValue.size {
                updateShapeLayer()
            }
        }
    }

    override var bounds: CGRect {
        didSet {
            if bounds.size != oldValue.size {
                updateShapeLayer()
            }
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateShapeLayer()
    }

    private func updateShapeLayer() {
        let dimension = min(bounds.width, bounds.height)
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: dimension, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.shadowPath = path.cgPath
        shapeLayer.fillColor = tintColor.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        clipsToBounds = false
        updateShadowProperties()
    }

    private func updateShadowProperties() {
        layer.shadowRadius = 4 * shadowAmount
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 4).applying(.init(scaleX: shadowAmount, y: shadowAmount))
        layer.shadowColor = UIColor.black.cgColor
    }

    override var intrinsicContentSize: CGSize {
        let dimension = 16
        return CGSize(width: dimension, height: dimension)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}
