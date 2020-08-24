//
//  SettingsScreenTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreenTests: BaseTest {

    func hideShowToggle(){
        let generalCategoryText = "1. General"
        let hiddenGeneralCategoryText = "General"
              
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        // Verify the category is not numbered when hidden and correct button states are shown.
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
              
        settingsScreen.toggleHideShowCategory(category: generalCategoryText, toggle: "Show")
        
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        settingsScreen.navigateToCategory(category: hiddenGeneralCategoryText)
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).element.exists)
        
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryUpButton].isEnabled)
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryDownButton].isEnabled)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).buttons[settingsScreen.settingsPageCategoryHideButton].isEnabled)

        // Verify category goes back to original spot when shown.
    
        settingsScreen.toggleHideShowCategory(category: generalCategoryText, toggle: "Hide")
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: hiddenGeneralCategoryText).element.exists)
        
        settingsScreen.navigateToCategory(category: "1. General")
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssertFalse(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryUpButton].isEnabled)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryDownButton].isEnabled)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.settingsPageCategoryHideButton].isEnabled)
    }
}
