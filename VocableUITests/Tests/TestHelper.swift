//
//  TestHelper.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class TestHelper: XCTestCase {
    override func setUp() {
        let app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
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
