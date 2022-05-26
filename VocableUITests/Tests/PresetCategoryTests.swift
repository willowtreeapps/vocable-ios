//
//  PresetCategoryTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 5/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PresetCategoryTests: BaseTest {
    let nameSuffix = "test"
    
    func testRenameCategory() {
        let categoryName = "General"
        let renamedCategory = categoryName + nameSuffix
        let categoryIdentifier = (CategoryIdentifier.general).identifier
        
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
        let isSelectedPredicate = NSPredicate(format: "isSelected == true")
        let query = XCUIApplication().cells.containing(isSelectedPredicate)
        XCTAssertEqual(query.staticTexts.element.label, renamedCategory)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryIdentifier)
    }
    
    func testRemoveCategory() {
        let categoryName = "Environment"
        
        //Remove the preset category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        SettingsScreen.removeCategoryButton.tap()
        SettingsScreen.alertRemoveButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        
        // Confirm that the category is removed from categories list
        _ = SettingsScreen.settingsPageAddCategoryButton.waitForExistence(timeout: 0.5)
        XCTAssertFalse(SettingsScreen.doesCategoryExist(categoryName))
        
        // Confirm that the category is removed from main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        XCTAssertFalse(MainScreen.locateAndSelectDestinationCategory(.environment))
    }
    
    func testShowHideButtonIsDisabledForMySayingsCategory() {
        let categoryName = "My Sayings"
        
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(SettingsScreen.showCategoryButton.isEnabled)
    }
    
    // For the first 5 preset categories, tap() the top left phrase, then verify that all selected phrases appear in "Recents"
    func testRecentScreen_ShowsPressedButtons(){
        var listOfSelectedPhrases: [String] = []
        var firstPhrase = ""
        let listOfCategoriesToSkip: [String] = [CategoryIdentifier.keyPad.identifier,
                                                CategoryIdentifier.mySayings.identifier,
                                                CategoryIdentifier.recents.identifier,
                                                CategoryIdentifier.listen.identifier]
        
        for categoryName in PresetCategories().list {
            
            // Skip the 123 (keypad), My Sayings, Recents, and Listen categories because their entries do not get added to 'Recents'
            if listOfCategoriesToSkip.contains(categoryName.identifier) {
                continue;
            }
            MainScreen.locateAndSelectDestinationCategory(categoryName)
            firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
            XCUIApplication().collectionViews.staticTexts[firstPhrase].tap()
            listOfSelectedPhrases.append(firstPhrase)
        }
        MainScreen.locateAndSelectDestinationCategory(.recents)
        
        for phrase in listOfSelectedPhrases {
            XCTAssertTrue(MainScreen.locatePhraseCell(phrase: phrase).exists, "Expected \(phrase) to appear in Recents category")
        }
    }
    
    func testDefaultCategoriesExist() {
        for categoryName in PresetCategories().list {
            MainScreen.locateAndSelectDestinationCategory(categoryName)
            XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryName.identifier, "Preset category with ID '\(categoryName.identifier)' was not found")
        }
    }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        MainScreen.locateAndSelectDestinationCategory(.keyPad)
        let firstKeypadNumber = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCUIApplication().collectionViews.staticTexts[firstKeypadNumber].tap()
        XCTAssertEqual(MainScreen.outputText.label, firstKeypadNumber)
    }
    
}
