//
//  PresetsOverrideTestCase.swift
//  VocableUITests
//
//  Created by Chris Stroud on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PresetsOverrideTestCase: XCTestCase {

    override class func setUp() {
        super.setUp()

        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .enableListeningMode)
            Environment(.overridePresets) {
                Presets {
                    Category("Custom Basic Needs") {
                        Phrase("Test Phrase")
                        Phrase("Another Phrase")
                        Phrase(id: "specific_id", "With some text")
                        Phrase(id: "another_id", languageCode: "es", "No sé donde estoy")
                    }
                    Category("Another Category") {
                        // Empty
                    }
                    Category(id: "custom-identifier", "Category Name Here") {
                        // Also Empty
                    }
                }
            }
        }
        app.launch()
    }

    func testCustomPresets() throws {

        // Use those custom presets!

        // Uncomment if you want to play with the categories on the simulator
        // Thread.sleep(until: .distantFuture)
    }
}
