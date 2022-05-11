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

    typealias Root = AccessibilityIdentifiers.Root

    enum Accessibility: String {
        case outputText
        case keyboardButton
        case settingsButton

        var element: XCUIElement {
            switch self {
            case .outputText:
                return app.staticTexts[AccessibilityIdentifiers.Root.OutputText.id]
            case .keyboardButton:
                return app.buttons[AccessibilityIdentifiers.Shared.KeyboardButton.id]
            case .settingsButton:
                return app.buttons[AccessibilityIdentifiers.Shared.SettingsButton.id]
            }
        }
    }
    
    static let categoryLeftButton = XCUIApplication().buttons["root.categories_carousel.left_chevron"]
    static let categoryRightButton = XCUIApplication().buttons["root.categories_carousel.right_chevron"]
    static let pageNumber = XCUIApplication().staticTexts["bottomPagination.pageNumber"]
    static let addPhraseLabel = XCUIApplication().cells["add_new_phrase"]
    
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
            categoryRightButton.tap()
           
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
}
