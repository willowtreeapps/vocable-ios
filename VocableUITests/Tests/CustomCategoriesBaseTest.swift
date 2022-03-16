//
//  CustomCategoriesBaseTest.swift
//  VocableUITests
//
//  Created by Rudy Salas on 3/10/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesBaseTest: BaseTest {
    
    private(set) var customCategoryName: String = ""
    
    override func setUp() {
        super.setUp()
        
        setCustomCategory(name: "Hi", numOfRandomLetters: 3)
        
        // Create a custom category and open it
        settingsScreen.navigateToSettingsCategoryScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategoryName)
        settingsScreen.openCategorySettings(category: customCategoryName)
    }
    
    private func setCustomCategory(name: String, numOfRandomLetters: Int) {
        customCategoryName = name + randomString(length: numOfRandomLetters)
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
