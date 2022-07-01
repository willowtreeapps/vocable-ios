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
}
