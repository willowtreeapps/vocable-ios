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
            XCTAssertEqual(MainScreen.outputText.label, phrase.utterance)
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
    
}
