//
//  MainScreenPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class MainScreenPaginationTests: CustomPhraseBaseTest {
    
    func testDeletingPhrasesAdjustsPagination() {
        for phrase in listOfPhrases.startIndex..<8 {
            CustomCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 2"
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        VTAssertPaginationEquals(1, of: 2)
        
        // Delete one of the phrases to reduce the total number of pages to 1.
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: customCategoryName)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
        SettingsScreen.alertDeleteButton.tap()
        
        // Navigate back to the home screen to verify that the total pages reduced from 2 to 1.
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
    func testAddingPhrasesAdjustsPagination() {
        // Use array slices to split the phrase bank into two sets of 8 phrases
        let listMidpoint = listOfPhrases.count / 2
        let firstSetOfPhrases = listOfPhrases[..<listMidpoint]
        let secondSetOfPhrases = listOfPhrases[listMidpoint...]
        
        firstSetOfPhrases.forEach { phrase in
            CustomCategoriesScreen.addPhrase(phrase)
        }
        
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 1"
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
        
        // Add 8 more phrases to verify that the pagination adjusts as expected; "Page 1 of 2"
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: customCategoryName)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        secondSetOfPhrases.forEach { phrase in
            CustomCategoriesScreen.addPhrase(phrase)
        }
        
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        VTAssertPaginationEquals(1, of: 2)
    }
    
    func testCanScrollPagesWithPaginationArrows() {
        // Add enough phrases to push the total number of pages to 2
        listOfPhrases.forEach { phrase in
            CustomCategoriesScreen.addPhrase(phrase)
        }
        
        // Return to the Main Screen and navigate to the test category
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        
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
        let categoryTitleCell = CategoryTitleCellIdentifier(customCategoryIdentifier!)

        // Add enough phrases to ensure that rotating the device will add a page; 7 phrases
        for phrase in listOfPhrases.startIndex..<7 {
            CustomCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Return to the Main Screen and navigate to the test category
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(categoryTitleCell.categoryIdentifier)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryTitleCell.identifier)
        
        // Verify we're on the first page
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
