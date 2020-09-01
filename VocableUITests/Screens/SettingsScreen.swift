//
//  SettingsScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 5/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreen {
    let mainScreen = MainScreen()
    let keyboardScreen = KeyboardScreen()
    
    let categoriesButton = XCUIApplication().collectionViews.staticTexts["Categories and Phrases"]
    let leaveCategoryDetailButton = XCUIApplication().buttons["arrow.left"]
    let leaveCategoriesButton = XCUIApplication().buttons["arrow.left"]
    let exitSettingsButton = XCUIApplication().buttons["settings.dismissButton"]
    let otherElements = XCUIApplication().collectionViews.cells.otherElements
    let settingsPageNextButton = XCUIApplication().buttons["bottomPagination.right_chevron"]
    let settingsPageCategoryUpButton = "chevron.up"
    let settingsPageCategoryDownButton = "chevron.down"
    let settingsPageCategoryHideButton = "eye.slash.fill"
    let settingsPageCategoryShowButton = "eye.fill"
    let settingsPageAddCategoryButton = XCUIApplication().buttons["settingsCategory.addCategoryButton"]
    let alertContinueButton = XCUIApplication().buttons["Continue Editing"]
    let alertDiscardButton = XCUIApplication().buttons["Discard"]
    let alertDeleteButton = XCUIApplication().buttons["Delete"]
    
    
   
    func openCategorySettings(category: String) {
        if otherElements.containing(.staticText, identifier: category).element.exists {
            otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        } else {
            settingsPageNextButton.tap()
            otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        }
    }
    
    func toggleHideShowCategory(category: String, toggle: String) {
        var toggleLabel = ""
        switch toggle {
        case "Hide":
            toggleLabel = settingsPageCategoryHideButton
        case "Show":
            toggleLabel = settingsPageCategoryShowButton
        default:
            break
        }

        if otherElements.containing(.staticText, identifier: category).element.exists {
            otherElements.containing(.staticText, identifier: category).buttons[toggleLabel].tap()
        } else {
            settingsPageNextButton.tap()
           otherElements.containing(.staticText, identifier: category).buttons[toggleLabel].tap()
        }
    }
    
    
    func navigateToCategory(category: String){
        while !otherElements.containing(.staticText, identifier: category).element.exists {
            settingsPageNextButton.tap()
            if (mainScreen.pageNumber.label.contains("Page 1")){
                break
            }
        }
    }
    
    func addCategory(categoryName: String){
        settingsPageAddCategoryButton.tap()
        let newCategory = keyboardScreen.randomString(length: 5)
        keyboardScreen.typeText(newCategory)
        keyboardScreen.checkmarkAddButton.tap()
    }
    
    func navigateToSettingsCategoryScreen() {
        mainScreen.settingsButton.tap()
        categoriesButton.tap()
    }
    
    func navigateToMainScreenFromSettings(from: String){
           switch from {
           case "categoryDetails":
               leaveCategoryDetailButton.tap()
               leaveCategoriesButton.tap()
               exitSettingsButton.tap()
           case "categories":
               leaveCategoriesButton.tap()
               exitSettingsButton.tap()
           case "settings":
               exitSettingsButton.tap()
           default:
               break;
           }
       }
}
