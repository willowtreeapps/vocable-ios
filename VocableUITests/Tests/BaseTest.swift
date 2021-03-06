//
//  BaseScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class BaseTest: XCTestCase {
    let mainScreen = MainScreen()
    let keyboardScreen = KeyboardScreen()
    let settingsScreen = SettingsScreen()
    let customCategoriesScreen = CustomCategoriesScreen()
    
    override func setUp() {
        let app = XCUIApplication()
        app.launchEnvironment["RefactoredInterfaceEnabled"] = "1"
        continueAfterFailure = false
        app.launch()

        addUIInterruptionMonitor(withDescription: "SpeechRecognition") { (alert) -> Bool in
            alert.buttons["OK"].tap()
            return true
        }
    }
    
    override func tearDown() {
        super.tearDown()
        captureFailure(name: self.name)
    }
    
    func captureFailure(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .deleteOnSuccess
        add(attachment)
    }
}
