//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen {
    let app = XCUIApplication()
    static let categoryLeftButton = app.collectionViews.containing(.other, identifier: "Horizontal scroll bar, 1 page").children(matching: .cell).element(boundBy: 3).children(matching: .staticText).element
    static let categoryRightButton = app.collectionViews.containing(.other, identifier: "Horizontal scroll bar, 1 page").children(matching: .cell).element(boundBy: 5).children(matching: .staticText).element
}
