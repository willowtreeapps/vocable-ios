//
//  BorderedView.swift
//  Vocable
//
//  Created by Chris Stroud on 10/15/19.
//  Copyright © 2019 WilowTree. All rights reserved.
//

import UIKit

private class VCShapeLayer: CAShapeLayer {

    override func action(forKey event: String) -> CAAction? {
        var action = super.action(forKey: event)
        if action == nil, UIView.inheritedAnimationDuration != 0, ["path", "shadowPath"].contains(event) {
            if let basicAction = super.action(forKey: "backgroundColor") as? CABasicAnimation {
                let newAction = basicAction.copy() as! CABasicAnimation
                newAction.keyPath = event
                newAction.fromValue = presentation()?.value(forKey: event)
                action = newAction
            }
        }
        return action
    }
}

@IBDesignable
class BorderedView: UIView {

    override class var layerClass: AnyClass {
        return VCShapeLayer.self
    }

    private var shapeLayer: VCShapeLayer {
        return self.layer as! VCShapeLayer
    }

    private var needsShadowUpdate = false
    private var needsShapeUpdate = false
    private var needsAppearanceUpdate = false

    private func setNeedsShapeUpdate() {
        needsShapeUpdate = true
        setNeedsLayout()
    }

    private func setNeedsAppearanceUpdate() {
        needsAppearanceUpdate = true
        setNeedsLayout()
    }

    private func setNeedsShadowUpdate() {
        needsShadowUpdate = true
        setNeedsLayout()
    }

    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            guard oldValue != roundedCorners else { return }
            setNeedsShapeUpdate()
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
            guard oldValue != shadowAmount else { return }
            setNeedsShadowUpdate()
        }
    }

    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            guard oldValue != shadowColor else { return }
            setNeedsShadowUpdate()
        }
    }

    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            guard oldValue != shadowOffset else { return }
            setNeedsShadowUpdate()
        }
    }

    @IBInspectable var shadowOpacity: CGFloat = .zero {
        didSet {
            guard oldValue != shadowOpacity else { return }
            setNeedsShadowUpdate()
        }
    }

    @IBInspectable var shadowRadius: CGFloat = .zero {
        didSet {
            guard oldValue != shadowRadius else { return }
            setNeedsShadowUpdate()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = .zero {
        didSet {
            guard oldValue != cornerRadius else { return }
            setNeedsShapeUpdate()
        }
    }

    @IBInspectable var fillColor: UIColor = .white {
        didSet {
            guard oldValue != fillColor else { return }
            setNeedsAppearanceUpdate()
        }
    }

    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            guard oldValue != borderColor else { return }
            setNeedsAppearanceUpdate()
        }
    }

    @IBInspectable var borderWidth: CGFloat = .zero {
        didSet {
            guard oldValue != borderWidth else { return }
            setNeedsShapeUpdate()
            setNeedsAppearanceUpdate()
        }
    }

    var borderDashPattern: [NSNumber]? {
        didSet {
            guard oldValue != borderDashPattern else { return }
            setNeedsAppearanceUpdate()
        }
    }

    private var shapeRect: CGRect = .zero {
        didSet {
            guard oldValue != shapeRect else { return }
            setNeedsShapeUpdate()
        }
    }

    override var frame: CGRect {
        didSet {
            guard oldValue != frame else { return }
            shapeRect = bounds
        }
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            shapeRect = bounds
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        guard newWindow != nil else { return }

        setNeedsShapeUpdate()
        setNeedsShadowUpdate()
        setNeedsAppearanceUpdate()
    }

    override func prepareForInterfaceBuilder() {
        setNeedsShapeUpdate()
        setNeedsShadowUpdate()
        setNeedsAppearanceUpdate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if needsShapeUpdate {
            _updateShape()
        }

        if needsShadowUpdate {
            _updateShadow()
        }

        if needsAppearanceUpdate {
            _updateAppearance()
        }
    }

    private func _updateShadow() {

        guard window != nil else { return }

        shapeLayer.shadowRadius = shadowRadius * shadowAmount
        shapeLayer.shadowOpacity = Float(shadowOpacity)
        shapeLayer.shadowOffset = shadowOffset.applying(.init(scaleX: shadowAmount, y: shadowAmount))
        shapeLayer.shadowColor = shadowColor.cgColor
        shapeLayer.masksToBounds = false

        needsShadowUpdate = false
    }

    private func _updateAppearance() {

        guard window != nil else { return }

        shapeLayer.lineDashPattern = borderDashPattern
        shapeLayer.lineJoin = .round
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.masksToBounds = false
        shapeLayer.fillColor = fillColor.cgColor

        needsAppearanceUpdate = false
    }

    private func _updateShape() {

        guard !shapeRect.isEmpty, window != nil else { return }

        let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
        let boundsRect = CGRect(origin: .zero, size: shapeRect.size)
        let insetRect = boundsRect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
        let path = UIBezierPath(roundedRect: insetRect,
                                byRoundingCorners: roundedCorners,
                                cornerRadii: cornerRadii).cgPath
        shapeLayer.path = path
        shapeLayer.shadowPath = path

        needsShapeUpdate = false
    }

    override func action(for layer: CALayer, forKey event: String) -> CAAction? {
        if event == "backgroundColor" {
            return nil
        }
        return super.action(for: layer, forKey: event)
    }
}
