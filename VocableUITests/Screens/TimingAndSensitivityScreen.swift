//
//  TimingAndSensitivityScreen.swift
//  VocableUITests
//
//  Created by Rhonda Oglesby on 4/18/22.
//

import XCTest

class TimingAndSensitivityScreen: BaseScreen {
    
    let timingAndSensitivityLabel = XCUIApplication().staticTexts["Timing and Sensitivity"]
    let hoverTimeDecreaseButton = XCUIApplication().buttons["remove"]
    let hoverTimeIncreaseButton = XCUIApplication().buttons["add"]
    let cursorLowButton = XCUIApplication().buttons["Low"]
    let cursorMediumButton = XCUIApplication().buttons["Medium"]
    let cursorHighButton = XCUIApplication().buttons["High"]
    
    let rangeOfHoverTimes = ["0.5s", "1.0s", "1.5s", "2.0s", "2.5s", "3.0s", "3.5s", "4.0s", "4.5s", "5.0s"]
    let defaultHoverTimeIndex = 1
    
    var currentHoverTimeIndex = 1
    var defaultHoverTime = "1.0s"
    var currentHoverTime = "1.0s"
    var minimumHoverTime = "0.5s"
    var maximumHoverTime = "5.0s"
    
    override init() {
        defaultHoverTime = rangeOfHoverTimes[defaultHoverTimeIndex]
        currentHoverTime = defaultHoverTime
        minimumHoverTime = rangeOfHoverTimes[0]
        maximumHoverTime = rangeOfHoverTimes.last!
    }
    
    func hasMinimumHoverTimeBeenReached() -> Bool {
        if currentHoverTimeIndex == 0 {
            return true
        }
        return false
    }
    
    func hasMaximumHoverTimeBeenReached() -> Bool {
        if currentHoverTimeIndex == rangeOfHoverTimes.count - 1 {
            return true
        }
        return false
    }

    func decreaseHoverTime() {
        self.hoverTimeDecreaseButton.tap()
        currentHoverTimeIndex -= 1
        currentHoverTime = rangeOfHoverTimes[currentHoverTimeIndex]
    }
    
    func increaseHoverTime() {
        self.hoverTimeIncreaseButton.tap()
        currentHoverTimeIndex += 1
        currentHoverTime = rangeOfHoverTimes[currentHoverTimeIndex]
    }
}
