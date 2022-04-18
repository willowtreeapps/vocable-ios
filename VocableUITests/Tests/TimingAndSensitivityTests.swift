//
//  TimingAndSensitivityTests.swift
//  VocableUITests
//
//  Created by Rhonda Oglesby on 4/18/22.
//

import XCTest

class TimingAndSensitivity: BaseTest {
    
    func testHoverTimeIncreasesAndDecreases() {
        settingsScreen.navigateToTimingAndSensitivityScreen()
 
        // Verify default Hover Time value.
        XCTAssertTrue(app.staticTexts[timingScreen.defaultHoverTime].exists)
        
        // Verify Hover Time can be decreased to the minimum value.
        repeat {
            timingScreen.decreaseHoverTime()
            XCTAssertTrue(app.staticTexts[timingScreen.currentHoverTime].exists)
            XCTAssertTrue(timingScreen.hoverTimeIncreaseButton.isEnabled)
        } while !timingScreen.hasMinimumHoverTimeBeenReached()
        
        XCTAssertTrue(app.staticTexts[timingScreen.minimumHoverTime].exists)
        XCTAssertTrue(!timingScreen.hoverTimeDecreaseButton.isEnabled)
        
        // Verify Hover Time can be increased to the maximum value.
        repeat {
            timingScreen.increaseHoverTime()
            XCTAssertTrue(app.staticTexts[timingScreen.currentHoverTime].exists)
            XCTAssertTrue(timingScreen.hoverTimeDecreaseButton.isEnabled)
        } while !timingScreen.hasMaximumHoverTimeBeenReached()
        
        XCTAssertTrue(app.staticTexts[timingScreen.maximumHoverTime].exists)
        XCTAssertTrue(!timingScreen.hoverTimeIncreaseButton.isEnabled)
        
        // Verify the latest Hover Time set persists after leaving and returning to Settings.
        timingScreen.navBarBackButton.tap()
        timingScreen.navBarDismissButton.tap()
        settingsScreen.navigateToTimingAndSensitivityScreen()
 
        XCTAssertTrue(app.staticTexts[timingScreen.currentHoverTime].exists)
    }
    
    func testSensitivitySettings() {
        settingsScreen.navigateToTimingAndSensitivityScreen()
 
        // Verify default sensitivity setting.
        XCTAssertTrue(timingScreen.cursorMediumButton.isSelected)
        XCTAssertTrue(!timingScreen.cursorLowButton.isSelected)
        XCTAssertTrue(!timingScreen.cursorHighButton.isSelected)
        
        timingScreen.cursorLowButton.tap()
        XCTAssertTrue(timingScreen.cursorLowButton.isSelected)
        XCTAssertTrue(!timingScreen.cursorMediumButton.isSelected)
        XCTAssertTrue(!timingScreen.cursorHighButton.isSelected)
        
        timingScreen.cursorHighButton.tap()
        XCTAssertTrue(timingScreen.cursorHighButton.isSelected)
        XCTAssertTrue(!timingScreen.cursorLowButton.isSelected)
        XCTAssertTrue(!timingScreen.cursorMediumButton.isSelected)
        
        settingsScreen.returnToMainScreenFromSettingsScreen()
        settingsScreen.navigateToTimingAndSensitivityScreen()
        XCTAssertTrue(timingScreen.cursorHighButton.isSelected)
    }
}
