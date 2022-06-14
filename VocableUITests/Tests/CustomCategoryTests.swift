//
//  CustomCategoryTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoryTests: CustomCategoryBaseTest {
    
    func testAddCustomCategory() {
        XCTAssertTrue(SettingsScreen.locateCategoryCell(customCategoryName).element.isEnabled)
        XCTAssertTrue(SettingsScreen.locateCategoryCell(customCategoryName).element.exists)
    }
    
    func testCanContinueEditingCategoryName() {
        let renamedCategory = customCategoryName + nameSuffix
        
        SettingsScreen.openCategorySettings(category: customCategoryName)
        SettingsScreen.renameCategoryButton.tap()
        KeyboardScreen.typeText(nameSuffix)
        KeyboardScreen.navBarDismissButton.tap()
        XCTAssertTrue(KeyboardScreen.alertMessageLabel.exists)
        
        SettingsScreen.alertContinueButton.tap()
        XCTAssertTrue(KeyboardScreen.keyboardTextView.staticTexts[renamedCategory].exists)

        KeyboardScreen.checkmarkAddButton.tap()
        SettingsScreen.navBarBackButton.tap()
        XCTAssertTrue(SettingsScreen.locateCategoryCell(renamedCategory).element.isEnabled)
        XCTAssertTrue(SettingsScreen.locateCategoryCell(renamedCategory).element.exists)
   }
    
    func testCanDiscardEditingCategoryName() {
        SettingsScreen.openCategorySettings(category: customCategoryName)
        SettingsScreen.renameCategoryButton.tap()
        KeyboardScreen.typeText(nameSuffix)
        KeyboardScreen.navBarDismissButton.tap()
        XCTAssertTrue(KeyboardScreen.alertMessageLabel.exists)
        
        SettingsScreen.alertDiscardButton.tap()
        XCTAssertEqual(SettingsScreen.title.label, customCategoryName)
        
        SettingsScreen.navBarBackButton.tap()
        XCTAssertTrue(SettingsScreen.locateCategoryCell(customCategoryName).element.exists)
    }
    
    func testCanRenameCategory() {
        let renamedCategory = customCategoryName + nameSuffix
        
        SettingsScreen.openCategorySettings(category: customCategoryName)
        SettingsScreen.renameCategoryButton.tap()
        KeyboardScreen.typeText(nameSuffix)
        KeyboardScreen.checkmarkAddButton.tap()
        XCTAssertEqual(SettingsScreen.title.label, renamedCategory)
        
        SettingsScreen.navBarBackButton.tap()
        XCTAssertTrue(SettingsScreen.locateCategoryCell(renamedCategory).element.exists)
    }
    
    func testCanRemoveCategory() {
        XCTAssertTrue(SettingsScreen.doesCategoryExist(customCategoryName))
        
        SettingsScreen.openCategorySettings(category: customCategoryName)
        SettingsScreen.removeCategoryButton.tap()
        SettingsScreen.alertRemoveButton.tap()
        _ = SettingsScreen.addCategoryButton.waitForExistence(timeout: 0.5)
        XCTAssertFalse(SettingsScreen.doesCategoryExist(customCategoryName))
    }
  
    func testCanHideCategory() {
        // Verify that custom category is created
        XCTAssertTrue(SettingsScreen.doesCategoryExist(customCategoryName))
        
        // Verify that custom category appears on the main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertTrue(MainScreen.locateAndSelectCustomCategory(customCategoryName))
        
        // Hide the custom category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: customCategoryName)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        // Verify that when the category is hidden, up and down buttons are disabled.
        let hiddenCategory = SettingsScreen.locateCategoryCell(customCategoryName)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(hiddenCategory.element.isEnabled)

        // Verify that custom category doesn't appear on the main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertFalse(MainScreen.locateAndSelectCustomCategory(customCategoryName))
        
        // Show the custom category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: customCategoryName)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        // Verify that when the category is shown, up button is enabled and down button is disabled.
        let shownCategory = SettingsScreen.locateCategoryCell(customCategoryName)
        XCTAssertTrue(shownCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(shownCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(shownCategory.element.isEnabled)
    }
}
