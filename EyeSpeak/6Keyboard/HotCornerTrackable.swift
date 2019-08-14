//
//  HotCornerable.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/23/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

protocol HotCornerTrackable {
    var component: HotCornerGazeableComponent? { get set }
    var trackingEngine: TrackingEngine { get }
}
