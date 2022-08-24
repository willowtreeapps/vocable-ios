//
//  ScreenModel.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

// Defines a page model for a particular screen
protocol ScreenModel {
    associatedtype Elements

    static var screenIdentifier: String { get }
    static var elements: Elements { get }
}

extension ScreenModel {
    /// Allow for `SettingsScreen[\.privacyPolicyCell]`
    static subscript(_ id: KeyPath<Self.Elements, AXElement>) -> AXElement {
        elements[keyPath: id]
    }
}
