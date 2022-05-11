//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Updated by Rudy Salas, Canan Arikan, and Rhonda Oglesby on 03/30/2022
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: XCTestCase {
    
    let firstTestCategory = Category(id: "first_category", "First") {
        Phrase(id: "phrase_one", "Please help")
    }
    
    let secondTestCategory = Category(id: "second_category", "To Be Hidden") {
        Phrase(id: "phrase_two", "Hello")
    }
    
    let thirdTestCategory = Category(id: "third_category", "Third") {
        Phrase(id: "phrase_three", "I need a blanket")
    }
    
    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .enableListeningMode, .disableAnimations)
            Environment(.overridePresets) {
                Presets {
                    firstTestCategory
                    secondTestCategory
                    thirdTestCategory
                }
            }
        }
        app.launch()
    }
    
    func testSelectingCategoryChangesPhrases() {
        let firstCategory = CategoryIdentifier(firstTestCategory.presetCategory.id)
        let secondCategory = CategoryIdentifier(secondTestCategory.presetCategory.id)
        
        // Navigate to a category and grab it's first, top most, phrase.
        MainScreen.locateAndSelectDestinationCategory(firstCategory)
        let phraseOne = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCTAssertEqual(phraseOne, firstTestCategory.presetPhrases[0].utterance)
        
        // Navigate to a different category and verify the top most phrase listed has changed.
        MainScreen.locateAndSelectDestinationCategory(secondCategory)
        let phraseTwo = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCTAssertEqual(phraseTwo, secondTestCategory.presetPhrases[0].utterance)
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() {
        let customTestCategories = [firstTestCategory,
                                    secondTestCategory,
                                    thirdTestCategory]
        for category in customTestCategories {
            let phrase = category.presetPhrases[0]
            MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(category.presetCategory.id))
            _ = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).waitForExistence(timeout: 0.5)
            XCUIApplication().cells[phrase.id].tap()
            XCTAssertEqual(MainScreen.outputLabel.label, phrase.utterance)
        }
    }
    
    func testDisablingCategory() {
        let hiddenCategory = secondTestCategory
        SettingsScreen.navigateToSettingsCategoryScreen()
        XCTAssertTrue(SettingsScreen.locateCategoryCell(hiddenCategory.presetCategory.utterance).element.exists)

        // Navigate to the category and hide it.
        SettingsScreen.openCategorySettings(category: hiddenCategory.presetCategory.utterance)
        SettingsScreen.showCategoryButton.tap()
        
        // Return to the main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoryDetails()
        
        // Confirm that the category is no longer accessible.
        let isVisible = MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(hiddenCategory.presetCategory.id))
        XCTAssertFalse(isVisible)
    }
    
    // TODO: The following tests will be covered in a separate suite: PresetCategoryTests
    /*
     
    // For each preset category (the first 5 categories), tap() the top left
    // phrase, then verify that all selected phrases appear in "Recents"
   func testRecentScreen_ShowsPressedButtons(){
       var listOfSelectedPhrases: [String] = []
       var firstPhrase = ""
       
       for categoryName in PresetCategories().list {
           
           // Skip the 123 (keypad), My Sayings, Recents, and Listen categories because their entries do
           // not get added to 'Recents'
           if listOfCategoriesToSkip.contains(categoryName.id) {
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
           XCTAssertEqual(MainScreen.selectedCategoryCell.id, categoryName.id, "Preset category with ID '\(categoryName.id)' was not found")
       }
   }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        MainScreen.locateAndSelectDestinationCategory(.keyPad)
        let firstKeypadNumber = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCUIApplication().collectionViews.staticTexts[firstKeypadNumber].tap()
        XCTAssertEqual(MainScreen.outputLabel.label, firstKeypadNumber)
    }
   */
    
}
