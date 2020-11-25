//
//  QuarterCircle.swift
//  Vocable
//
//  Created by Joe Romero on 11/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class QuarterCircle: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        createQuarterCircle()
    }

    private func createQuarterCircle() {
        // Create shape for the corners of the screen, creates a quarter circle filling the lower fourth quadrant area of the unit circle.
        let width = self.bounds.size.width
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: width, y: 0.0))
        path.addArc(withCenter: CGPoint(x: 0.0, y: 0.0), radius: width, startAngle: 0, endAngle: 3 * (.pi/2), clockwise: true)
        path.close()
        UIColor.defaultCellBackgroundColor.set()
        path.fill()
    }

    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
