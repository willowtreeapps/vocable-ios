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
        let customPhrase = "ddingcustomcategoryphrasetest"
        let customCategory = "Createnewcategory"
        let createdCustomCategory = "8. "+customCategory
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."

        
        
        // Add a new Category and navigate into it
        settingsScreen.navigateToSettingsScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()

        // Verify Phrase is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)

        keyboardScreen.alertDiscardButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)
        settingsScreen.settingsPageNextButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Phrase can be added if continuing edit.
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)
        keyboardScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()

        XCTAssert(mainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }



}
