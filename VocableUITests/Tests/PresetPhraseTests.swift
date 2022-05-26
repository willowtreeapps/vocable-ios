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
                
        // Navigate to our test category and Add a phrase
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.addPhrase(customPhrase)
        
        // Verify that phrase does exist in Category Details Screen
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(customPhrase))
        
        // Verify that phrase does exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.environment)
        XCTAssertTrue(MainScreen.phraseDoesExist(customPhrase))
    }
    
    func testEditPresetPhrase() {
        let customPhrase = "ab"
        let category = "Personal Care"
                
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Define the query that gives us the first phrase listed
        let originalPhrase = CustomCategoriesScreen.firstPhraseCell.staticTexts.firstMatch.label
        
        CustomCategoriesScreen.firstPhraseCell.staticTexts[originalPhrase].tap()
        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
   
        // Verify that the original phrase doesn't exist in Category Details Screen
        XCTAssertFalse(CustomCategoriesScreen.phraseDoesExist(originalPhrase))
        
        // Verify that updated phrase exists in Category Details Screen
        let updatedPhrase = originalPhrase + customPhrase
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(updatedPhrase))
        
        // Verify that updated phrase exists in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.personalCare)
        XCTAssertTrue(MainScreen.phraseDoesExist(updatedPhrase))
    }
    
    func testDeletePresetPhrase() {
        let category = "Basic Needs"
                
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Define the query that gives us the first phrase listed
        let firstPhrase = CustomCategoriesScreen.firstPhraseCell.staticTexts.firstMatch.label
        
        CustomCategoriesScreen.firstPhraseCell.buttons[.settings.editPhrases.deletePhraseButton].tap()
        SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        
        // Verify that phrase doesn't exist in Category Details Screen
        XCTAssertFalse(CustomCategoriesScreen.phraseDoesExist(firstPhrase))
        
        // Verify that phrase doesn't exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        XCTAssertFalse(MainScreen.phraseDoesExist(firstPhrase))
    }
    
    func testEditPhrasesButtonIsDisabledForNumberPadCategory() {
        let categoryName = "123"
           
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(CustomCategoriesScreen.editCategoryPhrasesButton.isEnabled)
    }
        
    func testEditPhrasesButtonIsDisabledForRecentsCategory() {
        let categoryName = "Recents"
       
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(CustomCategoriesScreen.editCategoryPhrasesButton.isEnabled)
    }
        
    func testAddDuplicatePhrasesToMySayings() {
        let testPhrase = "Test"
        
        MainScreen.keyboardButton.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.favoriteButton.tap()
        KeyboardScreen.navBarDismissButton.tap()
       
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        XCTAssertTrue(MainScreen.phraseDoesExist(testPhrase), "Expected the first phrase \(testPhrase) to be added to and displayed in 'My Sayings'")
        
        // Add the same phrase again to the My Sayings
        MainScreen.addPhraseButton.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
        KeyboardScreen.createDuplicateButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        
        // Assert that now we have two cells containing the same phrase
        let phrasePredicate = NSPredicate(format: "label MATCHES %@", testPhrase)
        let phraseQuery = XCUIApplication().staticTexts.containing(phrasePredicate)
        _ = phraseQuery.element.waitForExistence(timeout: 1)
        XCTAssertEqual(phraseQuery.count, 2, "Expected both phrases to be present in 'My Sayings'")
    }
}
