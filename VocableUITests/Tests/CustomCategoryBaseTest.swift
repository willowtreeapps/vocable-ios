//
//  CustomCategoryBaseTest.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 4/5/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoryBaseTest: BaseTest {

    private(set) var customCategoryName: String = "Test"
    private(set) var nameSuffix: String = "add"
    
    override func setUp() {
        super.setUp()
        
        SettingsScreen.navigateToSettingsCategoryScreen()
        CustomCategoriesScreen.createCustomCategory(categoryName: customCategoryName)
    }
}
