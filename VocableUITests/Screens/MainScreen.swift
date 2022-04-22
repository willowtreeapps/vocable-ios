//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen: BaseScreen {
    
    private static let app = XCUIApplication()
    
    static let settingsButton = XCUIApplication().buttons["root.settingsButton"]
    static let outputLabel = XCUIApplication().staticTexts["root.outputTextLabel"]
    static let keyboardNavButton = XCUIApplication().buttons["root.keyboardButton"]
    static let categoryLeftButton = XCUIApplication().buttons["root.categories_carousel.left_chevron"]
    static let categoryRightButton = XCUIApplication().buttons["root.categories_carousel.right_chevron"]
    static let pageNumber = XCUIApplication().staticTexts["bottomPagination.pageNumber"]
    static let addPhraseLabel = XCUIApplication().staticTexts["mainScreen.addPhrase"]
    
    // Find the current selected category and return it as a CategoryTitleCellIdentifier
    static var selectedCategoryCell: CategoryTitleCellIdentifier {
        let identifierPrefix = CategoryTitleCellIdentifier.categoryTitleCellPrefix
        let identifierPredicate = NSPredicate(format: "identifier CONTAINS %@", identifierPrefix)
        let isSelectedPredicate = NSPredicate(format: "isSelected == true")
        
        // Build our query that first finds all category title cells, then finds among those the one that is selected
        let query = XCUIApplication().cells.containing(identifierPredicate).containing(isSelectedPredicate)
        
        // Return the selected category's full identifier
        return CategoryTitleCellIdentifier(query.element.identifier)!
    }
    
    static func isTextDisplayed(_ text: String) -> Bool {
        return app.collectionViews.staticTexts[text].waitForExistence(timeout: 10)
    }
    
    /// Traverse the categories until the destination category is found, then tap on the category to ensure its phrases appear.
    ///
    ///  Categories are interacted with via their identifier, which we represent with the CategoryIdentifier type struct.
    static func locateAndSelectDestinationCategory(_ destinationCategory: CategoryIdentifier) {
        let titleCellIdentifier = CategoryTitleCellIdentifier(destinationCategory).identifier
        let destinationCell = app.cells[titleCellIdentifier]
        let selectedCell = app.cells[selectedCategoryCell.identifier]
        
        repeat {
            
            if (destinationCell.exists) {
                destinationCell.tap()
                break
            }
            categoryRightButton.tap()
           
            // We break the loop when we return to our original starting point
        } while (!selectedCell.waitForExistence(timeout: 0.5))
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
