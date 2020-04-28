//
//  UIHeadGazeTrackingWindow.swift
//  Vocable
//
//  Created by Chris Stroud on 4/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class UIHeadGazeTrackingWindow: UIWindow {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.rootViewController = UIHeadGazeViewController()
    }
}
