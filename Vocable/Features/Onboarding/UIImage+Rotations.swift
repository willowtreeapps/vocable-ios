//
//  UIImage+Rotations.swift
//  Vocable
//
//  Created by Joe Romero on 11/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

extension UIImage {
    func rotationFor(placement: ButtonPlacement) -> UIImage {
        switch placement {
        case .leadingBottom:
            return self.rotate(radians: 3 * .pi / 2)
        case .trailingTop:
            return self.rotate(radians: .pi / 2)
        case .trailingBottom:
            return self.rotate(radians: .pi)
        default:
            return self
        }
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return rotatedImage ?? self
        }

        return self
    }
}

extension GazeableCornerButton {
    func addArcAnimation() {
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 3
        animation.fillMode = .forwards
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 1.0
        animation.repeatCount = .infinity

        let shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer)
        shapeLayer.strokeColor = UIColor.systemGreen.cgColor
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
