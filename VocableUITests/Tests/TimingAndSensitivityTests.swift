//
//  TimingAndSensitivityTests.swift
//  VocableUITests
//
//  Created by Rhonda Oglesby on 4/21/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class TimingAndSensitivity: BaseTest {

    func testHoverTimeIncreasesAndDecreases() {
        SettingsScreen.navigateToTimingAndSensitivityScreen()

        // Verify default Hover Time value.
        XCTAssertTrue(XCUIApplication().staticTexts[TimingAndSensitivityScreen.defaultHoverTime].exists)

        // Verify Hover Time can be decreased to the minimum value.
        repeat {
            TimingAndSensitivityScreen.decreaseHoverTime()
            XCTAssertTrue(XCUIApplication().staticTexts[TimingAndSensitivityScreen.currentHoverTime].exists)
            XCTAssertTrue(TimingAndSensitivityScreen.hoverTimeIncreaseButton.isEnabled)
        } while !TimingAndSensitivityScreen.hasMinimumHoverTimeBeenReached()

        XCTAssertTrue(XCUIApplication().staticTexts[TimingAndSensitivityScreen.minimumHoverTime].exists)
        XCTAssertFalse(TimingAndSensitivityScreen.hoverTimeDecreaseButton.isEnabled)

        // Verify Hover Time can be increased to the maximum value.
        repeat {
            TimingAndSensitivityScreen.increaseHoverTime()
            XCTAssertTrue(XCUIApplication().staticTexts[TimingAndSensitivityScreen.currentHoverTime].exists)
            XCTAssertTrue(TimingAndSensitivityScreen.hoverTimeDecreaseButton.isEnabled)
        } while !TimingAndSensitivityScreen.hasMaximumHoverTimeBeenReached()

        XCTAssertTrue(XCUIApplication().staticTexts[TimingAndSensitivityScreen.maximumHoverTime].exists)
        XCTAssertFalse(TimingAndSensitivityScreen.hoverTimeIncreaseButton.isEnabled)
        
        // Verify the latest Hover Time set persists after leaving and returning to Settings.
        TimingAndSensitivityScreen.navBarBackButton.tap()
        TimingAndSensitivityScreen.navBarDismissButton.tap()
        SettingsScreen.navigateToTimingAndSensitivityScreen()

        XCTAssertTrue(XCUIApplication().staticTexts[TimingAndSensitivityScreen.currentHoverTime].exists)
      }
  }
