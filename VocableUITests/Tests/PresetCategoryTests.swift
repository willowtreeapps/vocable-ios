//
//  CustomCategoryTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PresetCategoryTests: BaseTest {
    let nameSuffix = "test"
    
    func testRenameCategory() {
        let categoryName = "General"
        let renamedCategory = categoryName + nameSuffix
        let categoryIdentifier = CategoryTitleCellIdentifier(CategoryIdentifier.general).identifier
        
        //Rename the preset category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        SettingsScreen.renameCategoryButton.tap()
        KeyboardScreen.typeText(nameSuffix)
        KeyboardScreen.checkmarkAddButton.tap()
        XCTAssertEqual(SettingsScreen.categoryDetailsTitle.label, renamedCategory)
        
        SettingsScreen.navBarBackButton.tap()
        XCTAssertTrue(SettingsScreen.doesCategoryExist(renamedCategory))
        
        // Return to the main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        
        // Confirm that the category is renamed from main screen
        MainScreen.locateAndSelectDestinationCategory(.general)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryIdentifier)
        //XCUIApplication().cells.staticTexts["Generaltest"].label
    }
    
    func testRemoveCategory() {
        let categoryName = "Environment"
        let categoryIdentifier = CategoryTitleCellIdentifier(CategoryIdentifier.environment).identifier

        //Remove the preset category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        SettingsScreen.removeCategoryButton.tap()
        SettingsScreen.alertRemoveButton.tap()
        XCTAssertFalse(SettingsScreen.doesCategoryExist(categoryName))
        
        // Return to the main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        
        // Confirm that the category is no longer accessible from main screen
        for category in PresetCategories().list {
            // If we come across the category we expect to be removed, fail the test. Otherwise the test will pass
            MainScreen.locateAndSelectDestinationCategory(category.categoryIdentifier)
            if (MainScreen.selectedCategoryCell.identifier == categoryIdentifier) {
                XCTFail("The category with identifier, '\(categoryIdentifier)', was not removed as expected.")
            }
        }
    }
    
    func testShowHideButtonIsDisabledForMySayingsCategory() {
        let categoryName = "My Sayings"
       
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(SettingsScreen.showCategoryButton.isEnabled)
    }
     
}
