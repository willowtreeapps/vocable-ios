//
//  CursorView.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/25/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class CursorView: UIView {

    struct Constants {
        static let innerCircleDiameter = CGFloat(10.0)
        static let borderWidth = CGFloat(2.0)
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    private var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
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
        path.addArc(withCenter: center, radius: dimension * 0.8, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        path.addArc(withCenter: center, radius: dimension * 0.3, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        shapeLayer.fillColor = tintColor.cgColor
        shapeLayer.backgroundColor = UIColor.clear.cgColor
    }

    override var intrinsicContentSize: CGSize {
        let dimension = 32
        return CGSize(width: dimension, height: dimension)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}
