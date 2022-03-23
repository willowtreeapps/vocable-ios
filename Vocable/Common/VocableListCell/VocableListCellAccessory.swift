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
    }

    let content: Content
    let isEnabled: Bool

    private static func systemImage(_ imageName: String, symbolConfiguration: UIImage.SymbolConfiguration? = nil) -> UIImage {
        var image = UIImage(systemName: imageName)!
        if let symbolConfiguration = symbolConfiguration {
            image = image.applyingSymbolConfiguration(symbolConfiguration)!
        }
        return image
    }

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

        let image = systemImage(symbolName, symbolConfiguration: trailingDefaultSymbolConfiguration)
        return VocableListCellAccessory(content: .image(image), isEnabled: isEnabled)
    }

    static func toggle(isOn: Bool, isEnabled: Bool = true) -> VocableListCellAccessory {
        return VocableListCellAccessory(content: .toggle(isOn: isOn), isEnabled: isEnabled)
    }

    static func == (lhs: VocableListCellAccessory, rhs: VocableListCellAccessory) -> Bool {
        lhs.isEnabled == rhs.isEnabled &&
        lhs.content == rhs.content
    }
}
