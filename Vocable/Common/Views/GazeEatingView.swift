//
//  GazeEatingView.swift
//  Vocable
//
//  Created by Steve Foster on 3/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class GazeEatingView: UIView {

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        // Hit test this view's subviews, otherwise swallow the gazeable hit test
        super.gazeableHitTest(point, with: event) ?? self
    }

}
