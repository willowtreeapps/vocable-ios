//
//  GazeableCornerButton.swift
//  Vocable
//
//  Created by Joe Romero on 12/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazeableCornerButton: GazeableButton {

    var placement: CornerPlacement = .leadingTop {
        didSet {
            updateBackgroundImagesForCurrentParameters()
        }
    }

    override func renderBackgroundImage(withFillColor fillColor: UIColor, withHighlight isHighlighted: Bool) -> UIImage {
        let image = UIGraphicsImageRenderer(bounds: bounds).image { _ in
            let strokeColor = isHighlighted ? UIColor.cellBorderHighlightColor : fillColor
            let size = self.bounds.insetBy(dx: borderWidth, dy: borderWidth)
            let path = UIBezierPath()
            path.lineWidth = borderWidth
            let point = CGPoint(x: borderWidth, y: borderWidth)
            path.move(to: point)
            path.addLine(to: CGPoint(x: size.width, y: borderWidth))
            path.addArc(withCenter: point, radius: size.width, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: point)
            fillColor.setFill()
            strokeColor.setStroke()
            path.fill()
            path.stroke()
        }
        return image.rotationFor(placement: placement)
    }
}

extension GazeableCornerButton {

    var originPoint: CGPoint {
        switch placement {
        case .leadingTop:
            return CGPoint(x: 0, y: 0)
        case .leadingBottom:
            return CGPoint(x: 0, y: self.bounds.maxY)
        case .trailingTop:
            return CGPoint(x: self.bounds.maxX, y: 0)
        case .trailingBottom:
            return CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
        }
    }

    func addArcAnimation() {
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 4
        animation.fillMode = .forwards
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 1.0
        animation.repeatCount = .infinity

        let shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer)
        shapeLayer.strokeColor = UIColor.cellSelectionColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 0
        let path = UIBezierPath()
        path.addArc(withCenter: originPoint, radius: bounds.width, startAngle: 0, endAngle: .pi, clockwise: placement.clockwise)
        shapeLayer.path = path.cgPath
        shapeLayer.add(animation, forKey: "customAnimation")
    }

    func removeCustomAnimations() {
        for layer in self.layer.sublayers ?? [] {
            layer.removeAnimation(forKey: "customAnimation")
        }
    }
}
