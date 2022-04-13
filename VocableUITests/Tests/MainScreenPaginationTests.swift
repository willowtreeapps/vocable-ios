//
//  MainScreenPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class MainScreenPaginationTests: CustomPhraseBaseTest {
    
    // In order to ensure this test passes on both an iPhone and iPad device, we will add 16 phrase (2 pages on an iPad)
    // then remove 8 of them so that the pages reduce from 2 to 1 page.
    func testDeletingPhrasesAdjustsPagination() {
        for phrase in listOfPhrases.startIndex..<listOfPhrases.endIndex {
            customCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 2"
        customCategoriesScreen.returnToMainScreenFromEditPhrases()
        mainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        XCTAssertTrue(mainScreen.paginationLeftButton.isEnabled)
        
        // Delete 8 of the phrases to reduce the total number of pages to 1.
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
        for _ in 1...8 {
            customCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
            settingsScreen.alertDeleteButton.tap()
        }
        
        // Navigate back to the home screen to verify that the total pages reduced from 2 to 1.
        customCategoriesScreen.returnToMainScreenFromEditPhrases()
        mainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 1)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
    }
    
    // In order to ensure there are 2 pages on iPad devices, we'll need 16 total phrases.
    func testAddingPhrasesAdjustsPagination() {
        // Use array slices to split the phrase bank into two sets of 8 phrases
        let listMidpoint = listOfPhrases.count / 2
        let firstSetOfPhrases = listOfPhrases[..<listMidpoint]
        let secondSetOfPhrases = listOfPhrases[listMidpoint...]
        
        // Add the first 8 phrases
        for phrase in firstSetOfPhrases.startIndex..<firstSetOfPhrases.endIndex {
            customCategoriesScreen.addPhrase(firstSetOfPhrases[phrase])
        }
        
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 1"
        customCategoriesScreen.returnToMainScreenFromEditPhrases()
        mainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 1)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        
        // Add 8 more phrases to verify that the pagination adjusts as expected; "Page 1 of 2"
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
        for phrase in secondSetOfPhrases.startIndex..<secondSetOfPhrases.endIndex {
            customCategoriesScreen.addPhrase(secondSetOfPhrases[phrase])
        }
        
        customCategoriesScreen.returnToMainScreenFromEditPhrases()
        mainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        XCTAssertTrue(mainScreen.paginationLeftButton.isEnabled)
    }
    
    func testCanScrollPagesWithPaginationArrows() {
        // Add enough phrases to push the total number of pages to at leaset 2 for iPad and iPhone (16).
        for phrase in listOfPhrases.startIndex..<listOfPhrases.endIndex {
            customCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Return to the Main Screen and navigate to the test category
        customCategoriesScreen.returnToMainScreenFromEditPhrases()
        mainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        
        // Verify that the category's pagination is "Page 1 of 2"; page next buttons are enabled
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        XCTAssertTrue(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        
        // Tap right arrow; expected "Page 2 of 2"
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.currentPageNumber, 2)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        
        // Tap right arrow; expected "Page 1 of 2"
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        
        // Tap left arrow; expected "Page 2 of 2"
        mainScreen.paginationLeftButton.tap()
        XCTAssertEqual(mainScreen.currentPageNumber, 2)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        
        // Tap left arrow; expected "Page 1 of 2"
        mainScreen.paginationLeftButton.tap()
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
    }
    
    func testPaginationAdjustsToDeviceOrientation() {
        let categoryTitleCell = CategoryTitleCellIdentifier(customCategoryIdentifier!)

        // Add 13 phrases. This is the min num of phrases to ensure an additional page is needed after device rotation on an iPad.
        for phrase in listOfPhrases.startIndex..<13 {
            customCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Return to the Main Screen and navigate to the test category
        customCategoriesScreen.returnToMainScreenFromEditPhrases()
        mainScreen.locateAndSelectDestinationCategory(categoryTitleCell.categoryIdentifier)
        XCTAssertEqual(mainScreen.selectedCategoryCell.identifier, categoryTitleCell.identifier)
        
        // Capture current total number of pages
        let totalPagesInPortrait = mainScreen.totalPageCount
        let expectedTotalPagesInLandscape = totalPagesInPortrait + 1
        
        // Verify we're on the first page
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        
        // Rotate the device
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = mainScreen.settingsButton.waitForExistence(timeout: 1) // Wait for rotation to complete
        
        // Ensure that the total number of pages increases and the current page stays the same
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, expectedTotalPagesInLandscape)
        
        // Rotate back to Portrait
        XCUIDevice.shared.orientation = .portrait
        _ = mainScreen.settingsButton.waitForExistence(timeout: 1) // Wait for rotation to complete
        
        // Verify that the pagination returns to initial state
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, totalPagesInPortrait)
    }
    
}
