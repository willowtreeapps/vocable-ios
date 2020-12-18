//
//  SettingsScreenTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreenTests: BaseTest {

    func testHideShowToggle() {
        let generalCategoryText = "1. General"
        let hiddenGeneralCategoryText = "General"

        settingsScreen.navigateToSettingsCategoryScreen()

        // Verify the category is not numbered when hidden and correct button states are shown.

        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)

        settingsScreen.toggleHideShowCategory(category: generalCategoryText, toggle: "Hide")
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)

        settingsScreen.navigateToCategory(category: hiddenGeneralCategoryText)

        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryUpButton].isEnabled)
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryDownButton].isEnabled)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryShowButton].isEnabled)

        // Verify category goes back to original spot when shown.

        settingsScreen.toggleHideShowCategory(category: hiddenGeneralCategoryText, toggle: "Show")
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).element.exists)

        settingsScreen.navigateToCategory(category: generalCategoryText)
        settingsScreen.settingsPageNextButton.tap()

        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryUpButton].isEnabled)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryDownButton].isEnabled)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryHideButton].isEnabled)
    }

    func testReorder() {
        let generalCategoryText = "1. General"
        let basicNeedsCategoryText = "2. Basic Needs"
        
        let expectedGeneralCategoryText = "2. General"
        let expectedbasicNeedsCategoryText = "1. Basic Needs"

        settingsScreen.navigateToSettingsCategoryScreen()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: basicNeedsCategoryText).element.exists)

        settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryDownButton].tap()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: expectedGeneralCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: expectedbasicNeedsCategoryText).element.exists)
        
        settingsScreen.otherElements.containing(.staticText, identifier: expectedGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryUpButton].tap()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: basicNeedsCategoryText).element.exists)

    }

    func testAddCustomCategory() {

        let customCategory = "ddingcustomcategorytest"
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."

        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.settingsPageAddCategoryButton.tap()

        // Verify Category is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)

        settingsScreen.alertDiscardButton.tap()
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: "A").element.exists)
        settingsScreen.settingsPageNextButton.tap()
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Category can be added if continuing edit.
        settingsScreen.settingsPageAddCategoryButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)
        settingsScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customCategory)
        keyboardScreen.checkmarkAddButton.tap()
        settingsScreen.navigateToCategory(category: "9. A"+customCategory)

        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: "9. A"+customCategory).element.exists)

    }

}
