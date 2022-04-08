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
        XCTAssertTrue(settingsScreen.locateCategoryCell(customCategoryName).element.isEnabled)
        XCTAssertTrue(settingsScreen.locateCategoryCell(customCategoryName).element.exists)
    }
    
    func testCanContinueEditingCategoryName() {
        let renamedCategory = customCategoryName + nameSuffix
        
        settingsScreen.openCategorySettings(category: customCategoryName)
        settingsScreen.renameCategoryButton.tap()
        keyboardScreen.typeText(nameSuffix)
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertTrue(keyboardScreen.alertMessageLabel.exists)
        
        settingsScreen.alertContinueButton.tap()
        XCTAssertTrue(keyboardScreen.keyboardTextView.staticTexts[renamedCategory].exists)

        keyboardScreen.checkmarkAddButton.tap()
        settingsScreen.leaveCategoriesButton.tap()
        XCTAssertTrue(settingsScreen.locateCategoryCell(renamedCategory).element.isEnabled)
        XCTAssertTrue(settingsScreen.locateCategoryCell(renamedCategory).element.exists)
   }
    
    func testCanDiscardEditingCategoryName() {
        settingsScreen.openCategorySettings(category: customCategoryName)
        settingsScreen.renameCategoryButton.tap()
        keyboardScreen.typeText(nameSuffix)
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertTrue(keyboardScreen.alertMessageLabel.exists)
        
        settingsScreen.alertDiscardButton.tap()
        XCTAssertEqual(settingsScreen.categoryDetailsTitle.label, customCategoryName)
        
        settingsScreen.leaveCategoriesButton.tap()
        XCTAssertTrue(settingsScreen.locateCategoryCell(customCategoryName).element.exists)
    }
    
    func testCanRenameCategory() {
        let renamedCategory = customCategoryName + nameSuffix
        
        settingsScreen.openCategorySettings(category: customCategoryName)
        settingsScreen.renameCategoryButton.tap()
        keyboardScreen.typeText(nameSuffix)
        keyboardScreen.checkmarkAddButton.tap()
        XCTAssertEqual(settingsScreen.categoryDetailsTitle.label, renamedCategory)
        
        settingsScreen.leaveCategoriesButton.tap()
        XCTAssertTrue(settingsScreen.locateCategoryCell(renamedCategory).element.exists)
    }
    
    func testCanRemoveCategory() {
        XCTAssertTrue(settingsScreen.doesCategoryExist(customCategoryName))
        
        settingsScreen.openCategorySettings(category: customCategoryName)
        settingsScreen.removeCategoryButton.tap()
        settingsScreen.alertRemoveButton.tap()
        XCTAssertFalse(settingsScreen.doesCategoryExist(customCategoryName))
    }
  
}
