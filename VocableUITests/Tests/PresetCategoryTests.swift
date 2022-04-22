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
        
        // Confirm that the category is renamed from categories list
        SettingsScreen.navBarBackButton.tap()
        XCTAssertTrue(SettingsScreen.doesCategoryExist(renamedCategory))
        
        // Confirm that the category is renamed from main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        MainScreen.locateAndSelectDestinationCategory(.general)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryIdentifier)
        XCTAssertTrue(MainScreen.doesCategoryExist(renamedCategory))
    }
    
    func testRemoveCategory() {
        let categoryName = "Environment"

        //Remove the preset category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        SettingsScreen.removeCategoryButton.tap()
        SettingsScreen.alertRemoveButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        
        // Confirm that the category is removed from categories list
        XCTAssertFalse(SettingsScreen.doesCategoryExist(categoryName))
        
        // Confirm that the category is removed from main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertFalse(MainScreen.doesCategoryExist(categoryName))
    }
    
    func testShowHideButtonIsDisabledForMySayingsCategory() {
        let categoryName = "My Sayings"
       
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(SettingsScreen.showCategoryButton.isEnabled)
    }
     
}
