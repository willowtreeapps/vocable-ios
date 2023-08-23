//
//  CategoryPhrasesPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CategoryPhrasesPaginationTests: PaginationBaseTest {
    
    func testCanNavigatePages() {
        // Navigate to our test category
        MainScreen.navigateToSettingsAndOpenCategory(name: ninePhrasesCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Verify that the user is on the first page and the next page buttons are enabled.
        VTAssertPaginationEquals(1, of: 2, enabledArrows: .both)
        
        // Use the RIGHT pagination button to traverse the pages, ending back on "Page 1 of X"
        for pageNumber in 1...CustomCategoriesScreen.totalPageCount {
            XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, pageNumber)
            CustomCategoriesScreen.paginationRightButton.tap()
        }
        XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, 1) // Confirm we return to the first page
        
        // Use the LEFT pagination button to traverse the pages, ending back on "Page 1 of X"
        for pageNumber in stride(from: CustomCategoriesScreen.totalPageCount, through: 1, by: -1) {
            CustomCategoriesScreen.paginationLeftButton.tap()
            XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, pageNumber)
        }
    }
    
    func testPagesAdjustToNewPhrases() {
        // Verify that the user is on the first page.
        MainScreen.navigateToSettingsAndOpenCategory(name: twoPhrasesCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Add 1 more phrase to push the total number of pages to 2.
        CustomCategoriesScreen.addRandomPhrases(numberOfPhrases: 10)
        VTAssertPaginationEquals(1, of: 2, enabledArrows: .both)
        
        // Remove the additional phrase to verify that the page count reduces, back to the original count
        for _ in 1...10 {
            CustomCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
            SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        }
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
    // It is expected that the pagination left and right arrows are disabled when there is only 1 total page
    func testNextPageButtonsDisabled() {
        // Navigate to our test category and open the 'Edit Phrases' screen
        MainScreen.navigateToSettingsAndOpenCategory(name: twoPhrasesCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Verify the page counts and that buttons appear; both buttons are disabled.
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
}
