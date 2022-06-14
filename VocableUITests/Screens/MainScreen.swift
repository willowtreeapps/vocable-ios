//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen: BaseScreen {
    
    // MARK: Home screen elements

    static let outputText = XCUIApplication().staticTexts[.root.outputText]
    static let keyboardButton = XCUIApplication().buttons[.shared.keyboardButton]
    static let settingsButton = XCUIApplication().buttons[.shared.settingsButton]
    static let categoryBackButton = XCUIApplication().buttons[.root.categoryBackButton]
    static let categoryForwardButton = XCUIApplication().buttons[.root.categoryForwardButton]
    static let pageNumberText = XCUIApplication().staticTexts[.shared.pagination.pageLabel]
    static let addPhraseButton = XCUIApplication().cells[.root.addPhraseButton]
    
    // Find the current selected category and return it as a CategoryIdentifier
    static var selectedCategoryCell: CategoryIdentifier {
        let isSelectedPredicate = NSPredicate(format: "isSelected == true")
        
        // Build our query that first finds all category title cells, then finds among those the one that is selected
        let query = XCUIApplication().cells.containing(isSelectedPredicate)
        
        // Return the selected category's full identifier
        return CategoryIdentifier(query.element.identifier)
    }
    
    static func isTextDisplayed(_ text: String) -> Bool {
        return app.collectionViews.staticTexts[text].waitForExistence(timeout: 10)
    }
    
    /// Traverse the categories until the destination category is found, then tap on the category to ensure its phrases appear.
    /// The function returns true if the category is found, false if it is not.
    ///
    ///  Categories are interacted with via their identifier, which we represent with the CategoryIdentifier type struct.
    @discardableResult
    static func locateAndSelectDestinationCategory(_ destinationCategory: CategoryIdentifier) -> Bool {
        let destinationCell = app.cells[destinationCategory.identifier]
        let selectedCell = app.cells[selectedCategoryCell.identifier]
        
        repeat {
            
            if (destinationCell.exists) {
                destinationCell.tap()
                return true
            }
            categoryForwardButton.tap()
           
            // We break the loop when we return to our original starting point
        } while (!selectedCell.waitForExistence(timeout: 0.5))
        
        return false
    }
    
    @discardableResult
    static func locateAndSelectCustomCategory(_ destinationCategory: String) -> Bool {
        let destinationCell = app.cells.staticTexts[destinationCategory]
        let isSelectedPredicate = NSPredicate(format: "isSelected == true")
        
        // Return the selected category's full identifier
        let query = XCUIApplication().cells.containing(isSelectedPredicate)
        let selectedCell = app.cells[query.element.identifier]
        
        repeat {
            
            if (destinationCell.exists) {
                destinationCell.tap()
                return true
            }
            categoryForwardButton.tap()
           
            // We break the loop when we return to our original starting point
        } while (!selectedCell.waitForExistence(timeout: 0.5))
        
        return false
    }
    
    /// Assuming there is at least one page of phrases within a category, locate the cell containing the given phrase.
    static func locatePhraseCell(phrase: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label MATCHES %@", phrase)
        
        // Loop through each custom category page to find our phrase
        for _ in 1...totalPageCount {
            if app.cells.staticTexts.containing(predicate).element.exists {
                break
            } else {
                paginationRightButton.tap()
            }
        }
        return app.cells.staticTexts.containing(predicate).element
    }
    
    static func navigateToSettingsAndOpenCategory(name: String) {
        MainScreen.settingsButton.tap()
        SettingsScreen.categoriesAndPhrasesCell.tap()
        SettingsScreen.openCategorySettings(category: name)
    }

}
