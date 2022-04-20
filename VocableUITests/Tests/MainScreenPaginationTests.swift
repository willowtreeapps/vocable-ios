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
        listOfPhrases.forEach { phrase in
            CustomCategoriesScreen.addPhrase(phrase)
        }
        
        // Navigate to main screen to verify page numbers; expected to be "Page 1 of 2"
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        VTAssertPaginationEquals(1, of: 2)
        
        // Delete 8 of the phrases to reduce the total number of pages to 1.
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: customCategoryName)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        for _ in 1...8 {
            CustomCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
            SettingsScreen.alertDeleteButton.tap()
        }
        
        // Navigate back to the home screen to verify that the total pages reduced from 2 to 1.
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(customCategoryIdentifier!)
        VTAssertPaginationEquals(1, of: 1, enabledArrows: .none)
    }
    
    // In order to ensure there are 2 pages on iPad devices, we'll need 16 total phrases.
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
        // Add enough phrases to push the total number of pages to at leaset 2 for iPad and iPhone (16).
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

        // Add 13 phrases. This is the min num of phrases to ensure an additional page is needed after device rotation on an iPad.
        for phrase in listOfPhrases.startIndex..<13 {
            CustomCategoriesScreen.addPhrase(listOfPhrases[phrase])
        }
        
        // Return to the Main Screen and navigate to the test category
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(categoryTitleCell.categoryIdentifier)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryTitleCell.identifier)
        
        // Capture current total number of pages
        let totalPagesInPortrait = MainScreen.totalPageCount
        let expectedTotalPagesInLandscape = totalPagesInPortrait + 1
        
        // Verify we're on the first page
        XCTAssertEqual(MainScreen.currentPageNumber, 1)
        
        // Rotate the device
        XCUIDevice.shared.orientation = .landscapeLeft
        _ = MainScreen.settingsButton.waitForExistence(timeout: 1) // Wait for rotation to complete
        
        // Ensure that the total number of pages increases and the current page stays the same
        XCTAssertEqual(MainScreen.currentPageNumber, 1)
        XCTAssertEqual(MainScreen.totalPageCount, expectedTotalPagesInLandscape)
        
        // Rotate back to Portrait
        XCUIDevice.shared.orientation = .portrait
        _ = MainScreen.settingsButton.waitForExistence(timeout: 1) // Wait for rotation to complete
        
        // Verify that the pagination returns to initial state
        XCTAssertEqual(MainScreen.currentPageNumber, 1)
        XCTAssertEqual(MainScreen.totalPageCount, totalPagesInPortrait)
    }
    
}
