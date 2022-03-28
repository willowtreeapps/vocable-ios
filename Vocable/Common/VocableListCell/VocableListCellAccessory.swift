//
//  AccessoryAction.swift
//  Vocable
//
//  Created by Chris Stroud on 3/21/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

struct VocableListCellAccessory: Equatable {

    enum Content: Equatable {
        case toggle(isOn: Bool)
        case image(UIImage)

        static func == (lhs: Content, rhs: Content) -> Bool {
            switch (lhs, rhs) {
            case (.toggle(let isOnLeft), .toggle(let isOnRight)):
                return isOnLeft == isOnRight
            case (.image(let leftImage), .image(let rightImage)):
                return leftImage.isEqual(rightImage)
            default:
                return false
            }
        }
    }

    let content: Content
    let isEnabled: Bool

    private static var trailingDefaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
    }

    static func disclosureIndicator(isEnabled: Bool = true) -> VocableListCellAccessory {
        let symbolName: String
        if UITraitCollection.current.layoutDirection == .leftToRight {
            symbolName = "chevron.right"
        } else {
            symbolName = "chevron.left"
        }

        let image = UIImage(systemName: symbolName, withConfiguration: trailingDefaultSymbolConfiguration)!
        return VocableListCellAccessory(content: .image(image), isEnabled: isEnabled)
    }

    static func toggle(isOn: Bool, isEnabled: Bool = true) -> VocableListCellAccessory {
        return VocableListCellAccessory(content: .toggle(isOn: isOn), isEnabled: isEnabled)
    }
}
