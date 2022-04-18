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
            customCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Verify that the user is on the first page and the next page buttons are enabled.
        XCTAssertEqual(customCategoriesScreen.currentPageNumber, 1)
        XCTAssertTrue(customCategoriesScreen.paginationLeftButton.isEnabled)
        XCTAssertTrue(customCategoriesScreen.paginationRightButton.isEnabled)
        
        // Use the RIGHT pagination button to traverse the pages, ending back on "Page 1 of X"
        for pageNumber in 1...customCategoriesScreen.totalPageCount {
            XCTAssertEqual(customCategoriesScreen.currentPageNumber, pageNumber)
            customCategoriesScreen.paginationRightButton.tap()
        }
        XCTAssertEqual(customCategoriesScreen.currentPageNumber, 1) // Confirm we return to the first page
        
        // Use the LEFT pagination button to traverse the pages, ending back on "Page 1 of X"
        for pageNumber in stride(from: customCategoriesScreen.totalPageCount, through: 1, by: -1) {
            customCategoriesScreen.paginationLeftButton.tap()
            XCTAssertEqual(customCategoriesScreen.currentPageNumber, pageNumber)
        }
        
    }
    
    func testPagesAdjustToNewPhrases() {
        // Add 10 phrases; this results in 3 starting pages for an iPhone and 1 full page for an iPad
        for phrase in listOfPhrases.startIndex..<10 {
            customCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Verify that the user is on the first page.
        XCTAssertEqual(customCategoriesScreen.currentPageNumber, 1)
        
        // Add 3 more phrases to push the total number of pages from N to N+1.
        let originalPageCount = customCategoriesScreen.totalPageCount
        let expectedPageCountAfterAddingPhrase = originalPageCount + 1
        customCategoriesScreen.addRandomPhrases(numberOfPhrases: 3)
        XCTAssertEqual(customCategoriesScreen.totalPageCount, expectedPageCountAfterAddingPhrase)
        
        // Remove 3 phrases and verify that the page count reduces, back to the original count
        for _ in 1...3 {
            customCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
            _ = settingsScreen.alertRemoveButton.waitForExistence(timeout: 0.25)
            settingsScreen.alertDeleteButton.tap()
        }
        XCTAssertEqual(customCategoriesScreen.totalPageCount, originalPageCount)
    }
    
    // It is expected that the pagination left and right arrows are disabled when there is only 1 total page
    func testNextPageButtonsDisabled() {
        // Add 1 phrase so that the pagination buttons appear
        XCTAssertTrue(customCategoriesScreen.emptyStateAddPhraseButton.exists, "Expected a new category to be in empty state.")
        customCategoriesScreen.addRandomPhrases(numberOfPhrases: 1)
    
        // Verify the page counts and that buttons appear; buttons are disabled.
        VocableAssert().paginationEquals(1, of: 1, leftArrowEnabled: false, rightArrowEnabled: false)
    }
    
}
