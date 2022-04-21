//
//  TimingAndSensitivityScreen.swift
//  VocableUITests
//
//  Created by Rhonda Oglesby on 4/21/22.
//

import XCTest

class TimingAndSensitivityScreen: BaseScreen {

    private static let app = XCUIApplication()
    
    static let timingAndSensitivityLabel = app.staticTexts["Timing and Sensitivity"]
    static let hoverTimeDecreaseButton = app.buttons["remove"]
    static let hoverTimeIncreaseButton = app.buttons["add"]
    static let cursorLowButton = app.buttons["Low"]
    static let cursorMediumButton = app.buttons["Medium"]
    static let cursorHighButton = app.buttons["High"]

    static let rangeOfHoverTimes = ["0.5s", "1.0s", "1.5s", "2.0s", "2.5s", "3.0s", "3.5s", "4.0s", "4.5s", "5.0s"]
    static let defaultHoverTimeIndex = 1

    static var currentHoverTimeIndex = 1
    static var currentHoverTime = "1.0s"
    static let defaultHoverTime = "1.0s"
    static let minimumHoverTime = "0.5s"
    static let maximumHoverTime = "5.0s"
    
    static func decreaseHoverTime() {
         self.hoverTimeDecreaseButton.tap()
         currentHoverTimeIndex -= 1
         currentHoverTime = rangeOfHoverTimes[currentHoverTimeIndex]
     }

     static func increaseHoverTime() {
         self.hoverTimeIncreaseButton.tap()
         currentHoverTimeIndex += 1
         currentHoverTime = rangeOfHoverTimes[currentHoverTimeIndex]
     }

    static func hasMinimumHoverTimeBeenReached() -> Bool {
        if currentHoverTimeIndex == rangeOfHoverTimes.indices.first {
            return true
        }
        return false
    }

    static func hasMaximumHoverTimeBeenReached() -> Bool {
        if currentHoverTimeIndex == rangeOfHoverTimes.indices.last {
            return true
        }
        return false
    }
}
