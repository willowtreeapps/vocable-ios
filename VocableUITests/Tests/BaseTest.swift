//
//  BaseScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import XCTest

let app = XCUIApplication()

class BaseTest: XCTestCase {
    
    override func setUp() {
        
        app.configure {
            Arguments(.resetAppDataOnLaunch, .enableListeningMode, .disableAnimations)
        }
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
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
