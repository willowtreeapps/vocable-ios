//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest


class CustomCategoriesTest: BaseTest {

    func testaddNewPhrase() {
        let customPhrase = "ddingcustomcategorytest"
        let customCategory = "CreateNewCategory"
        let predicateCategoryStr = NSPredicate(format: "label CONTAINS 'CreateNewCategory'")
        settingsScreen.navigateToSettingsScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
      //  settingsScreen.navigateToCategory(predicateCategoryStr) // Dependent on PR392
        
        
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."

        
   //     settingsScreen.settingsPageAddCategoryButton.tap() // Dependent on PR392

        // Verify Category is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)

  //      keyboardScreen.alertDiscardButton.tap()  // Dependent on PR392
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)
 //       settingsScreen.settingsPageNextButton.tap() // Dependent on PR392
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Category can be added if continuing edit.
  //      settingsScreen.settingsPageAddCategoryButton.tap() // Dependent on PR392
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)
    //    keyboardScreen.alertContinueButton.tap() // Dependent on PR392

        keyboardScreen.typeText(customCategory)
 //       keyboardScreen.checkmarkAddButton.tap() // Dependent on PR392

        XCTAssert(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "8. A"+customPhrase).element.exists)
    }



}
