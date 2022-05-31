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
  
}
