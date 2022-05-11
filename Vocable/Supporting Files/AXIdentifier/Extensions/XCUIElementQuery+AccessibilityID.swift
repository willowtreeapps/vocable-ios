//
//  XCUIElementQuery+AccessibilityID.swift
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
