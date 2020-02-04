//
//  ViewControllerWrapperView.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class ViewControllerWrapperView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event), result != self else {
            return nil
        }
        return result
    }
}
