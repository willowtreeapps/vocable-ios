//
//  TimingAndSensitivityScreen.swift
//  VocableUITests
//
//  Created by Alex Facer on 7/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class TimingAndSensitivityScreen: BaseScreen {
    
    static let lowButton = XCUIApplication().buttons[.settings.timingAndSensitivity.lowSensitivityButton]
    static let mediumButton = XCUIApplication().buttons[.settings.timingAndSensitivity.mediumSensitivityButton]
    static let highButton = XCUIApplication().buttons[.settings.timingAndSensitivity.highSensitivityButton]
    static let reduceHoverTimeButton = XCUIApplication().buttons[.settings.timingAndSensitivity.decreaseHoverTimeButton]
    static let increaseHoverTimeButton = XCUIApplication().buttons[.settings.timingAndSensitivity.increaseHoverTimeButton]
    static let hoverTimeLabel = XCUIApplication().staticTexts[.settings.timingAndSensitivity.hoverTimeLabel]

}
