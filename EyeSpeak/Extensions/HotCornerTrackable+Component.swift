//
//  HotCornerTrackable+Component.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 5/1/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension HotCornerTrackable where Self: UIViewController {
    static func get(fromStoryboard storyboard: Storyboard, component: HotCornerGazeableComponent) -> Self {
        var controller = Self.get(fromStoryboard: storyboard)
        controller.component = component
        return controller
    }
}
