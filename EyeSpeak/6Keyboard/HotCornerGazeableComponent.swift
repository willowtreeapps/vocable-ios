//
//  HotCornerGazeableComponent.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/23/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

struct HotCornerGazeableComponent {
    var onUpperLeftGaze: ((Int?) -> Void)?
    var onUpperRightGaze: ((Int?) -> Void)?
    var onLowerLeftGaze: ((Int?) -> Void)?
    var onLowerRightGaze: ((Int?) -> Void)?
    var upperLeftTitle: String?
    var upperRightTitle: String?
    var lowerLeftTitle: String?
    var lowerRightTitle: String?
}
