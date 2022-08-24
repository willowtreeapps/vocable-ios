//
//  XCUIElementQuery+AXElement.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

public extension XCUIElementQuery {
    subscript(_ id: AccessibilityID) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier MATCHES %@", id.id)
        return self.element(matching: predicate)
    }
}

extension ScreenModel {
    public static func query(_ path: KeyPath<Elements, AXElement>) -> XCUIElement {
        XCUIApplication()
            .descendants(matching: .any)
            .matching(identifier: elements[keyPath: path].id)
            .firstMatch
    }
}
