//
//  BorderedView.swift
//  Vitality-One
//
//  Created by Chris Stroud on 10/15/19.
//  Copyright © 2019 Vitality. All rights reserved.
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

    private func updateBorderProperties() {
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.masksToBounds = false
    }

    private func updateShapeLayer() {
        guard bounds.size != .zero else { return }
        
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: bounds.size).insetBy(dx: borderWidth / 2, dy: borderWidth / 2), cornerRadius: cornerRadius).cgPath
        shapeLayer.path = path
        shapeLayer.shadowPath = path
        shapeLayer.fillColor = fillColor.cgColor
    }
}
