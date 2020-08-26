//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest


class CustomCategoriesTest: BaseTest {

    func addNewPhrase() {
        let customPhrase = "ddingcustomcategorytest"
        let customCategory = "CreateNewCategory"
        let predicateCategoryStr = NSPredicate(format: "label CONTAINS 'CreateNewCategory'")
        settingsScreen.navigateToSettingsScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
        settingsScreen.navigateToCategory(predicateCategoryStr)
        
        
        
        
        
    
        
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."

        
        settingsScreen.settingsPageAddCategoryButton.tap()

        // Verify Category is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)

        keyboardScreen.alertDiscardButton.tap()
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: "A").element.exists)
        settingsScreen.settingsPageNextButton.tap()
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Category can be added if continuing edit.
        settingsScreen.settingsPageAddCategoryButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)
        keyboardScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customCategory)
        keyboardScreen.checkmarkAddButton.tap()

        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: "8. A"+customCategory).element.exists)
    }



}
