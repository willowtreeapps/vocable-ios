//
//  CustomCategoriesBaseTest.swift
//  VocableUITests
//
//  Created by Rudy Salas on 3/10/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesBaseTest: BaseTest {
    
    var customCategory: String = ""
    
    override func setUp() {
        super.setUp()
        
        setCustomCategory(name: "Hi", numOfRandomLetters: 3)
        
        // Create a custom category and open it
        settingsScreen.navigateToSettingsCategoryScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
        settingsScreen.openCategorySettings(category: customCategory)
    }
    
    func setCustomCategory(name: String, numOfRandomLetters: Int) {
        customCategory = name + randomString(length: numOfRandomLetters).lowercased()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
