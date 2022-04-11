//
//  MainScreenPaginationTests.swift
//  VocableUITests
//
//  Created by Rudy Salas on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class MainScreenPaginationTests: BaseTest {
    
    let customCategoryName = "Test"
    
    // In order to ensure this test passes on both an iPhone and iPad device, we will add 16 phrase (2 pages on an iPad)
    // then remove 8 of them so that the pages reduce from 2 to 1 page.
    func testPaginationAdjustsToNumberOfPhrases() {
        // Add a custom category
        settingsScreen.navigateToSettingsCategoryScreen()
        let customCategory = customCategoriesScreen.createAndLocateCustomCategory(customCategoryName)
        
        // Add custom phrases to our category.
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 16)
        
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 2"
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        mainScreen.locateAndSelectDestinationCategory(customCategory)
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        XCTAssertTrue(mainScreen.paginationLeftButton.isEnabled)
        
        // Delete 8 of the phrases to reduce the total number of pages to 1.
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
        // TODO: Delete phrases
        
        // Navigate back to the home screen to verify that the total pages reduced from 2 to 1.
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 1)
        
        // Add the 8 phrases back to verify that the pagination adjusts as expected, back to 2 pages.
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
        customCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap() // TODO: Refactor to delete a matching phrase
        settingsScreen.alertDeleteButton.tap()
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        XCTAssertEqual(mainScreen.currentPageNumber, 1)
        XCTAssertEqual(mainScreen.totalPageCount, 2)
    }
    
    func testCanScrollPagesWithPaginationArrows() {
        // Add custom category
        settingsScreen.navigateToSettingsCategoryScreen()
        let customCategory = customCategoriesScreen.createAndLocateCustomCategory(customCategoryName)
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()

        // Add enough phrases to push the total number of pages to at leaset 2 for iPad and iPhone.
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 16)
        
        // Return to the Main Screen and navigate to the test category
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        mainScreen.locateAndSelectDestinationCategory(customCategory)
        
        // TODO: Refactor navigate method to use screen classes and be available in BaseScreen
        // TODO: Add computed property to BaseTest to retrieve ID of custom category for reference in these tests
        
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
        // Add a custom category
        settingsScreen.navigateToSettingsCategoryScreen()
        let customCategory = customCategoriesScreen.createAndLocateCustomCategory(customCategoryName)
        let categoryTitleCell = CategoryTitleCellIdentifier(customCategory)

        // Add 13 phrases. This ensures an additional page is needed after device rotation on an iPad.
        settingsScreen.openCategorySettings(category: customCategoryName)
        customCategoriesScreen.editCategoryPhrasesButton.tap()
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 13)
        
        // Return to the Main Screen and navigate to the test category
        // TODO: Refactor navigateToMainScreen...don't need current implementation...can nav from test, or each individual screen
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
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
