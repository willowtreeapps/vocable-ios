//
//  SettingsScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 5/19/20.
//  Updated by Canan Arikan and Rudy Salas on 05/27/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreen: BaseScreen {
    
    // MARK: Screen elements
    static let otherElements = XCUIApplication().collectionViews.cells.otherElements
    static let cells = XCUIApplication().cells
    
    // Settings Screen
    static let categoriesAndPhrasesCell = XCUIApplication().cells[.settings.categoriesAndPhrasesCell]
    static let timingAndSensitivityCell = XCUIApplication().cells[.settings.timingAndSensitivityCell]
    static let resetAppSettingsCell = XCUIApplication().cells[.settings.resetAppSettingsCell]
    static let listeningModeCell = XCUIApplication().cells[.settings.listeningModeCell]
    static let selectionModeCell = XCUIApplication().cells[.settings.selectionModeCell]
    static let privacyPolicyCell = XCUIApplication().cells[.settings.privacyPolicyCell]
    static let contactDevelopersCell = XCUIApplication().cells[.settings.contactDevelopersCell]
    
    // Categories and Phrases
    static let addCategoryButton = XCUIApplication().buttons[.settings.editCategories.addCategoryButton]

    // Category Details
    static let renameCategoryButton = XCUIApplication().buttons[.settings.editCategoryDetails.renameCategoryButton]
    static let showCategoryButton = XCUIApplication().buttons[.settings.editCategoryDetails.showCategoryToggle]
    static let removeCategoryButton = XCUIApplication().buttons[.settings.editCategoryDetails.removeCategoryButton]

    // MARK: Helpers
    
    static func openCategorySettings(category: String) {
        locateCategoryCell(category).staticTexts[category].tap()
    }
    
    @discardableResult
    static func locateCategoryCell(_ category: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        // Loop through each page to find our category
        for _ in 1...totalPageCount {
            if cells.staticTexts.containing(predicate).element.exists{
                break
            } else {
                paginationRightButton.tap()
            }
        }
        
        return categoryCellQuery(category)
    }
    
    private static func categoryCellQuery(_ category: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        let cellLabel = cells.staticTexts.containing(predicate).element.label
        
        return XCUIApplication().cells.containing(.staticText, identifier: cellLabel)
    }
    
    static func doesCategoryExist(_ category: String) -> Bool {
        var flag = false
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        
        // Loop through each custom category page to find our category
        for _ in 1...totalPageCount {
            if cells.staticTexts.containing(predicate).element.exists {
                flag = true
                break
            } else {
                MainScreen.paginationRightButton.tap()
            }
        }
        
        return flag
    }
    
    static func navigateToCategory(category: String) {
        while !otherElements.containing(.staticText, identifier: category).element.exists {
            paginationRightButton.tap()
            if MainScreen.pageNumberText.label.contains("Page 1") {
                break
            }
        }
    }
    
    static func navigateToSettingsCategoryScreen() {
        MainScreen.settingsButton.tap(afterWaitingForExistenceWithTimeout: 2)
        categoriesAndPhrasesCell.tap(afterWaitingForExistenceWithTimeout: 3)
        _ = addCategoryButton.waitForExistence(timeout: 0.5)
    }
    
    static func returnToMainScreen() {
        navBarDismissButton.tap()
    }
    
}
