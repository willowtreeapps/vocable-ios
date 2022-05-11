//
//  CustomCategoriesBaseTest.swift
//  VocableUITests
//
//  Created by Rudy Salas and Canan Arikan on 5/06/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PaginationBaseTest: XCTestCase {

    static private func phrases(count: Int) -> [Phrase] {
        (1...count).map { _ in
            Phrase("Hello")
        }
    }
    
    let eightPhrasesCategory = Category(id: "first_category", "Category 1", phrases: PaginationBaseTest.phrases(count: 8))
    let ninePhrasesCategory = Category(id: "second_category", "Category 2", phrases: PaginationBaseTest.phrases(count: 9))
    let sevenPhrasesCategory = Category(id: "third_category", "Category 3", phrases: PaginationBaseTest.phrases(count: 7))
    
    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .enableListeningMode)
            Environment(.overridePresets) {
                Presets {
                    eightPhrasesCategory
                    ninePhrasesCategory
                    sevenPhrasesCategory
                }
            }
        }
        app.launch()
    }
    
}
