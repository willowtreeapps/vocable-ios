//
//  CustomCategoriesScreen.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesScreen: BaseTest {

    func createCustomCategory(categoryName: String){
        settingsScreen.settingsPageAddCategoryButton.tap()
        keyboardScreen.typeText(categoryName)
        keyboardScreen.checkmarkAddButton.tap()
    }
    
    
}
