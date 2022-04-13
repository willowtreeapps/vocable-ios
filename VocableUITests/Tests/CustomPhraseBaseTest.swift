//
//  CustomCategoriesBaseTest.swift
//  VocableUITests
//
//  Created by Rudy Salas on 3/10/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomPhraseBaseTest: BaseTest {
    
    private(set) var customCategoryName: String = "Test"
    private(set) var customCategoryIdentifier: CategoryIdentifier?
    
    // To avoid potential duplication from random strings, we'll have our own phrase bank to pull from.
    private(set) var listOfPhrases: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"]
    
    override func setUp() {
        super.setUp()
        
        // Create a custom category and view its phrases
        settingsScreen.navigateToSettingsCategoryScreen()
        self.customCategoryIdentifier = customCategoriesScreen.createAndLocateCustomCategory(customCategoryName)
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
    }
    
}
