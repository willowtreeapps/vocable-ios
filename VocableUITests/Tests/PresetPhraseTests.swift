//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 04/19/20.
//  Copyright © 2022 WillowTree. All rights reserved.
//
import XCTest

class PresetPhraseTests: BaseTest {
    
    func testAddNewPhrase() {
        let customPhrase = "Add"
        let category = "Environment"
                
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        
        // Add a phrase
        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
        
        // Verify that phrase doesn't exist in Category Details Screen
        XCTAssertTrue(CustomCategoriesScreen.doesPhraseExist(customPhrase))
        
        // Verify that phrase doesn't exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.environment)
        XCTAssertTrue(MainScreen.doesPhraseExist(customPhrase))
    }
    
    func testEditPresetPhrase() {
        let customPhrase = "ab"
        let category = "Personal Care"
                
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Define the query that gives us the first phrase listed
        let firstPhraseId = XCUIApplication().cells.firstMatch.identifier
        let firstPhraseCell = XCUIApplication().cells[firstPhraseId]
        let firstPhrase = firstPhraseCell.staticTexts.firstMatch.label
        
        firstPhraseCell.tap()
        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
   
        // Verify that preset phrase doesn't exist in Category Details Screen
        XCTAssertFalse(CustomCategoriesScreen.doesPhraseExist(firstPhrase))
        
        // Verify that edited phrase exists in Category Details Screen
        XCTAssertTrue(CustomCategoriesScreen.doesPhraseExist(firstPhrase+customPhrase))
        
        // Verify that preset phrase doesn't exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.personalCare)
        XCTAssertFalse(MainScreen.doesPhraseExist(firstPhrase))
        
        // Verify that edited phrase exists in Main Screen
        XCTAssertTrue(MainScreen.doesPhraseExist(firstPhrase+customPhrase))
    }
    
    func testDeletePresetPhrase() {
        let category = "Basic Needs"
                
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Define the query that gives us the first phrase listed
        let firstPhraseId = XCUIApplication().cells.firstMatch.identifier
        let firstPhraseCell = XCUIApplication().cells[firstPhraseId]
        let firstPhrase = firstPhraseCell.staticTexts.firstMatch.label
        
        firstPhraseCell.buttons["deleteButton"].tap()
        SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        
        // Verify that phrase doesn't exist in Category Details Screen
        XCTAssertFalse(CustomCategoriesScreen.doesPhraseExist(firstPhrase))
        
        // Verify that phrase doesn't exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        XCTAssertFalse(MainScreen.doesPhraseExist(firstPhrase))
    }
    
    func testEditPhrasesButtonIsDisabledForNumberPadCategory() {
