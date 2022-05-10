//
//  CustomCategoriesBaseTest.swift
//  VocableUITests
//
//  Created by Rudy Salas and Canan Arikan on 5/06/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PaginationBaseTest: XCTestCase {
    
    let categoryOne = Category(id: "first_category", "Category 1") {
        Phrase("Please help")
        Phrase("Hello")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
    }
    
    let categoryTwo = Category(id: "second_category", "Category 2") {
        Phrase("Please help")
        Phrase("Hello")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
    }
    
    let categoryThree = Category(id: "third_category", "Category 3") {
        Phrase("Please help")
        Phrase("Hello")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
        Phrase("I need a blanket")
    }
    
    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .enableListeningMode)
            Environment(.overridePresets) {
                Presets {
                    categoryOne
                    categoryTwo
                    categoryThree
                }
            }
        }
        app.launch()
    }
    
}
