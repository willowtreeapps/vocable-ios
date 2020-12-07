//
//  GazeableCornerButton.swift
//  Vocable
//
//  Created by Joe Romero on 12/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class GazeableCornerButton: GazeableButton {

    var placement: ButtonPlacement = .leadingTop

    override func renderBackgroundImage(withFillColor fillColor: UIColor, withHighlight isHighlighted: Bool) -> UIImage {
        let quarterCircle = QuarterCircle(frame: self.frame.insetBy(dx: borderWidth * 0.5, dy: borderWidth * 0.5))
        quarterCircle.layer.masksToBounds = false
        let backgroundFillColor: UIColor = backgroundColor ?? .collectionViewBackgroundColor
        let strokeColor = isHighlighted ? UIColor.cellBorderHighlightColor : fillColor
        quarterCircle.fillColor = backgroundFillColor
        quarterCircle.lineWidth = borderWidth
        quarterCircle.strokeColor = strokeColor
        let bgImage = quarterCircle.asImage().rotationFor(placement: placement)
        return bgImage
    }
}
