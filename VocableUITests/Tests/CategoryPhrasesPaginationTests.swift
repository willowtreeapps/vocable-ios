//
//  CategoryPhrasesPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CategoryPhrasesPaginationTests: CustomPhraseBaseTest {
    
    func testCanNavigatePages() {
        // Add 11 phrases; this results in 3 total pages for an iPhone and 2 total pages for an iPad
        for phrase in listOfPhrases.startIndex..<11 {
            CustomCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Verify that the user is on the first page and the next page buttons are enabled.
        XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, 1)
        XCTAssertTrue(CustomCategoriesScreen.paginationLeftButton.isEnabled)
        XCTAssertTrue(CustomCategoriesScreen.paginationRightButton.isEnabled)
        
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
        // Add 10 phrases; this results in 3 starting pages for an iPhone and 1 full page for an iPad
        for phrase in listOfPhrases.startIndex..<10 {
            CustomCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Verify that the user is on the first page.
        XCTAssertEqual(CustomCategoriesScreen.currentPageNumber, 1)
        
        // Add 3 more phrases to push the total number of pages from N to N+1.
        let originalPageCount = CustomCategoriesScreen.totalPageCount
        let expectedPageCountAfterAddingPhrase = originalPageCount + 1
        CustomCategoriesScreen.addRandomPhrases(numberOfPhrases: 3)
        XCTAssertEqual(CustomCategoriesScreen.totalPageCount, expectedPageCountAfterAddingPhrase)
        
        // Remove 3 phrases and verify that the page count reduces, back to the original count
        for _ in 1...3 {
            CustomCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
            SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        }
        XCTAssertEqual(CustomCategoriesScreen.totalPageCount, originalPageCount)
    }
    
    // It is expected that the pagination left and right arrows are disabled when there is only 1 total page
    func testNextPageButtonsDisabled() {
        // Add 1 phrase so that the pagination buttons appear
        XCTAssertTrue(CustomCategoriesScreen.emptyStateAddPhraseButton.exists, "Expected a new category to be in empty state.")
        CustomCategoriesScreen.addRandomPhrases(numberOfPhrases: 1)
    
        // Verify the page counts and that buttons appear; both buttons are disabled.
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
}
