//
//  MainScreenPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class MainScreenPaginationTests: PaginationBaseTest {
    
    func testDeletingPhrasesAdjustsPagination() {
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 2"
        VTAssertPaginationEquals(1, of: 2)
        
        // Delete one of the phrases to reduce the total number of pages to 1.
        MainScreen.navigateToSettingsAndOpenCategory(name: categoryOne.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
        SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        
        // Navigate back to the home screen to verify that the total pages reduced from 2 to 1.
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
    func testAddingPhrasesAdjustsPagination() {
        // Navigate to our test category to verify initial page numbers; expected to be "Page 1 of 1"
        MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(categoryThree.presetCategory.id))
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
        
        // Use the '+ Add Phrase' button to add a new phrase
        MainScreen.addPhraseLabel.tap()
        KeyboardScreen.typeText("A")
        KeyboardScreen.checkmarkAddButton.tap()
        
        // Verify that the pagination adjusts as expected
        VTAssertPaginationEquals(1, of: 2, enabledArrows: .both)
    }
    
    func testCanScrollPagesWithPaginationArrows() {
        // Navigate to the test category
        MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(categoryTwo.presetCategory.id))
        
        // Verify that the category's pagination is "Page 1 of 2"; page next buttons are enabled
        VTAssertPaginationEquals(1, of: 2)
        
        // Tap right arrow; expected "Page 2 of 2"
        MainScreen.paginationRightButton.tap()
        VTAssertPaginationEquals(2, of: 2)
        
        // Tap right arrow; expected "Page 1 of 2"
        MainScreen.paginationRightButton.tap()
        VTAssertPaginationEquals(1, of: 2)
        
        // Tap left arrow; expected "Page 2 of 2"
        MainScreen.paginationLeftButton.tap()
        VTAssertPaginationEquals(2, of: 2)
        
        // Tap left arrow; expected "Page 1 of 2"
        MainScreen.paginationLeftButton.tap()
        VTAssertPaginationEquals(1, of: 2)
    }
    
    func testPaginationAdjustsToDeviceOrientation() {        
        // Verify we're on the first page
        MainScreen.locateAndSelectDestinationCategory(CategoryIdentifier(categoryThree.presetCategory.id))
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
        
        // Rotate the device
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = MainScreen.settingsButton.waitForExistence(timeout: 1) // Wait for rotation to complete
        
        // Ensure that the total number of pages increases and the current page stays the same
        VTAssertPaginationEquals(1, of: 2, enabledArrows: .both)
        
        // Rotate back to Portrait
        XCUIDevice.shared.orientation = .portrait
        _ = MainScreen.settingsButton.waitForExistence(timeout: 1) // Wait for rotation to complete
        
        // Verify that the pagination returns to initial state
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
}
