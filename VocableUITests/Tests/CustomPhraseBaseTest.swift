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
    
    override func setUp() {
        super.setUp()
        
        // Create a custom category and open it
        settingsScreen.navigateToSettingsCategoryScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategoryName)
        settingsScreen.openCategorySettings(category: customCategoryName)
    }
    
}
