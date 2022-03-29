//
//  SettingsScreenTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/24/20.
//  Updated by Canan Arikan and Rudy Salas on 03/28/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreenTests: BaseTest {

    func testHideShowToggle() {
        let category = "Environment"

        settingsScreen.navigateToSettingsCategoryScreen()
        XCTAssertTrue(settingsScreen.locateCategoryCell(category).element.exists)

        // Verify that when the category is hidden, up and down buttons are disabled.
        settingsScreen.openCategorySettings(category: category)
        settingsScreen.showCategorySwitch.tap()
        settingsScreen.leaveCategoryDetailButton.tap()
        
        settingsScreen.locateCategoryCell(category)
        XCTAssertFalse(settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryUpButton].isEnabled)
        XCTAssertFalse(settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryDownButton].isEnabled)
        XCTAssertTrue(settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryForwardButton].isEnabled)

        // Verify that when the category is shown, up and down buttons are enabled.
        settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryForwardButton].tap()
        settingsScreen.showCategorySwitch.tap()
        settingsScreen.leaveCategoryDetailButton.tap()
        
        settingsScreen.locateCategoryCell(category)
        XCTAssertTrue(settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryDownButton].isEnabled)
        XCTAssertTrue(settingsScreen.locateCategoryCell(category).buttons[settingsScreen.categoryForwardButton].isEnabled)
    }

    // We are disabling this test for now, it will be updated after the issue is completed: https://github.com/willowtreeapps/vocable-ios/issues/492
    func testReorder() {
        let generalCategoryText = "1. General"
        let basicNeedsCategoryText = "2. Basic Needs"
        
        let expectedGeneralCategoryText = "2. General"
        let expectedbasicNeedsCategoryText = "1. Basic Needs"

        settingsScreen.navigateToSettingsCategoryScreen()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: basicNeedsCategoryText).element.exists)

        settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.categoryDownButton].tap()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: expectedGeneralCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: expectedbasicNeedsCategoryText).element.exists)
        
        settingsScreen.otherElements.containing(.staticText, identifier: expectedGeneralCategoryText).buttons[settingsScreen.categoryUpButton].tap()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: basicNeedsCategoryText).element.exists)

    }

    // We are disabling this test for now, it will be fixed and moved to Custom Categories Tests: https://github.com/willowtreeapps/vocable-ios/issues/514
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
