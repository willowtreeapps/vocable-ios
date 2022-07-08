//
//  TimingAndSensitivityTests.swift
//  VocableUITests
//
//  Created by Alex Facer on 7/1/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class TimingAndSensitivityTests: BaseTest {
    
    func testSwitchCursorSensitivity() {
        //navigate to timing and sensitivity screen and check medium selected by default
        MainScreen.settingsButton.tap()
        SettingsScreen.timingAndSensitivityCell.tap()
        XCTAssertTrue(TimingAndSensitivityScreen.mediumButton.isSelected)
        
        //Tap low button and check medium is not selected
        TimingAndSensitivityScreen.lowButton.tap()
        XCTAssertTrue(TimingAndSensitivityScreen.lowButton.isSelected)
        XCTAssertFalse(TimingAndSensitivityScreen.mediumButton.isSelected)
        
        //Tap high button and check low is not selected
        TimingAndSensitivityScreen.highButton.tap()
        XCTAssertTrue(TimingAndSensitivityScreen.highButton.isSelected)
        XCTAssertFalse(TimingAndSensitivityScreen.lowButton.isSelected)
    }
    
    func testHoverTimeButtons() {
        //navigate to timing and sensitivity screen and check hover time is 1.0
        MainScreen.settingsButton.tap()
        SettingsScreen.timingAndSensitivityCell.tap()
        XCTAssertEqual(TimingAndSensitivityScreen.hoverTimeLabel.label, "1.0s")
        XCTAssertTrue(TimingAndSensitivityScreen.increaseHoverTimeButton.isEnabled)
        XCTAssertTrue(TimingAndSensitivityScreen.reduceHoverTimeButton.isEnabled)
        
        //decrease hover time and check minus icon is disabled
        TimingAndSensitivityScreen.reduceHoverTimeButton.tap()
        XCTAssertFalse(TimingAndSensitivityScreen.reduceHoverTimeButton.isEnabled)
        
        //increase hover time and ensure decrease button becomes enabled
        TimingAndSensitivityScreen.increaseHoverTimeButton.tap()
        XCTAssertTrue(TimingAndSensitivityScreen.reduceHoverTimeButton.isEnabled)
        
        //increase hover time to max 5.0s and check that increase button disabled
        while TimingAndSensitivityScreen.hoverTimeLabel.label != "5.0s" {
            TimingAndSensitivityScreen.increaseHoverTimeButton.tap()
        }
        XCTAssertFalse(TimingAndSensitivityScreen.increaseHoverTimeButton.isEnabled)
    }
    
}
