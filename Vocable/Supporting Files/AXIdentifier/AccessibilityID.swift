//
//  AccessibilityIdentifiers.swift
//  Vocable
//
//  Created by Rhonda Oglesby on 4/29/22.
//

import Foundation

public struct AccessibilityID: ExpressibleByStringLiteral {
    let id: String
    public init(stringLiteral value: StringLiteralType) {
        self.id = value
    }
}
