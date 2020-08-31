//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest


class CustomCategoriesTest: BaseTest {
    let customCategory = "Createnewcategory"


    func testAddNewPhrase() {
        let customPhrase = "ddingcustomcategoryphrasetest"
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."
        let createdCustomCategory = ("8. "+customCategory)

        
        
        // Add a new Category and navigate into it
        settingsScreen.navigateToSettingsScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()

        // Verify Phrase is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)

        settingsScreen.alertDiscardButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)
        settingsScreen.settingsPageNextButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Phrase can be added if continuing edit.
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)
        settingsScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()

        XCTAssert(mainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit(){
    // This test builds off of the last test.
        let customPhrase = "Addingcustomcategoryphrasetest"
        let createdCustomCategory = ("8. "+customCategory)

        // Navigate to Custom Category
        settingsScreen.navigateToSettingsScreen()
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        
        // Edit the phrase
        customCategoriesScreen.categoriesPageEditPhraseButton.tap()
        keyboardScreen.typeText("test")
        keyboardScreen.checkmarkAddButton.tap()
        XCTAssert(mainScreen.isTextDisplayed(customPhrase+"test"), "Expected the phrase \(customPhrase+"test") to be displayed")
    }
    
    func testDeleteCustomPhrase(){
       // This test builds off of the last test.
           let customPhrase = "Addingcustomcategoryphrasetesttest"
           let createdCustomCategory = ("8. "+customCategory)

           // Navigate to custom category
           settingsScreen.navigateToSettingsScreen()
           settingsScreen.openCategorySettings(category: createdCustomCategory)
        
           customCategoriesScreen.categoriesPageDeletePhraseButton.tap()
           settingsScreen.alertDeleteButton.tap()
           XCTAssertFalse(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to not be displayed")
        
        // Setup for next test
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("Addingcustomcategoryphrasetesttest")
        keyboardScreen.checkmarkAddButton.tap()

    }
    
    func testDuplicatePhrasesInDifferentCategories(){
        // This test builds off of the last test.

        let createdCustomCategory = ("8. "+customCategory)
        let customCategoryTwo = "Customcategorytwo"
        let customPhrase = "Addingcustomcategoryphrasetesttest"

        
        // Navigate to Settings and create a custom category
        settingsScreen.navigateToSettingsScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategoryTwo)
        
        // Add an existing custom phrase
        settingsScreen.openCategorySettings(category: "9. "+customCategoryTwo)
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Edit first phrase.
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        customCategoriesScreen.categoriesPageEditPhraseButton.tap()
        keyboardScreen.typeText("Two")
        keyboardScreen.checkmarkAddButton.tap()
        
        XCTAssert(mainScreen.isTextDisplayed(customPhrase+"two"), "Expected the phrase \(customPhrase+"two") to be displayed")
        
        // Go back to the other category
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.openCategorySettings(category: "9. "+customCategoryTwo)
        XCTAssert(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to be displayed")
        
        // Cleanup: Hide categories for now until delete feature is implemented so Automation tests pass:
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.toggleHideShowCategory(category: "8. "+customCategory, toggle: "Hide")
        settingsScreen.toggleHideShowCategory(category: "8. "+customCategoryTwo, toggle: "Hide")
        
    }
}
