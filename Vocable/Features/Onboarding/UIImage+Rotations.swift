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
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}

extension UIView {

    func rotationFor(placement: ButtonPlacement) {
        switch placement {
        case .leadingBottom:
            self.rotate(radians: 3 * .pi / 2)
        case .trailingTop:
            self.rotate(radians: .pi / 2)
        case .trailingBottom:
            self.rotate(radians: .pi)
        default:
            break
        }
    }

    func rotate(radians: CGFloat) {
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
}

extension UIButton {
    func addArcAnimation(with placement: ButtonPlacement) {

        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 3
        animation.fillMode = .forwards
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 1.0
        animation.repeatCount = 10

        var point: CGPoint = CGPoint()
        switch placement {
        case .leadingTop:
            point = CGPoint(x: 0, y: 0)
        case .leadingBottom:
            point = CGPoint(x: 0, y: self.bounds.maxY)
        case .trailingTop:
            point = CGPoint(x: self.bounds.maxX, y: 0)
        case .trailingBottom:
            point = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
        }

        // Animate background image on uibutton
        let shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer)
        shapeLayer.strokeColor = UIColor.systemGreen.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 0
        let path = UIBezierPath()
        path.addArc(withCenter: point, radius: 200, startAngle: 0, endAngle: .pi, clockwise: placement.clockwise)
        shapeLayer.path = path.cgPath
        shapeLayer.add(animation, forKey: "customAnimation")
    }
}

