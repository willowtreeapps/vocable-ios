//
//  BorderedView.swift
//  Vocable
//
//  Created by Chris Stroud on 10/15/19.
//  Copyright © 2019 WilowTree. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedView: UIView {

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }

    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            updateShapeLayer()
        }
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

    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            updateShadowProperties()
        }
    }

    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            updateShadowProperties()
        }
    }

    @IBInspectable var shadowOpacity: CGFloat = 1.0 {
        didSet {
            updateShadowProperties()
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            updateShadowProperties()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            updateShapeLayer()
            updateBorderProperties()
        }
    }

    @IBInspectable var fillColor: UIColor = .white {
        didSet {
            updateShapeLayer()
            updateBorderProperties()
        }
    }

    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            updateBorderProperties()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            updateBorderProperties()
        }
    }

    override var frame: CGRect {
        didSet {
            updateShapeLayer()
            updateBorderProperties()
        }
    }

    override var bounds: CGRect {
        didSet {
            updateShapeLayer()
            updateBorderProperties()
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        updateShapeLayer()
        updateBorderProperties()
    }

    override func prepareForInterfaceBuilder() {
        updateShapeLayer()
        setNeedsLayout()
        layoutIfNeeded()
    }

    private func updateShadowProperties() {
        shapeLayer.shadowRadius = shadowRadius * shadowAmount
        shapeLayer.shadowOpacity = Float(shadowOpacity)
        shapeLayer.shadowOffset = shadowOffset.applying(.init(scaleX: shadowAmount, y: shadowAmount))
        shapeLayer.shadowColor = shadowColor.cgColor
        shapeLayer.masksToBounds = false
    }

    private func updateBorderProperties() {
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.masksToBounds = false
    }

    private func updateShapeLayer() {
        guard bounds.size != .zero || frame.size != .zero else { return }
        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
        let boundsRect = CGRect(origin: .zero, size: bounds.size)
        let insetRect = boundsRect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
        let path = UIBezierPath(roundedRect: insetRect,
                                byRoundingCorners: roundedCorners,
                                cornerRadii: cornerRadii).cgPath
        shapeLayer.path = path
        shapeLayer.shadowPath = path
        shapeLayer.fillColor = fillColor.cgColor
    }
}
