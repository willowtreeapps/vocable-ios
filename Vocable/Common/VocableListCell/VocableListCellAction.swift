//
//  VocableListCellAction.swift
//  Vocable
//
//  Created by Chris Stroud on 3/23/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

struct VocableListCellAction: Equatable {

    typealias Action = () -> Void

    let image: UIImage
    let action: Action?
    let isEnabled: Bool
    let accessibilityIdentifier: String?
    let accessibilityLabel: String?
    
    private init(
        image: UIImage,
        isEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        action: Action? = nil
    ) {
        self.image = image
        self.isEnabled = isEnabled
        self.action = action
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    private init(
        systemImage imageName: String,
        symbolConfiguration: UIImage.SymbolConfiguration? = nil,
        isEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        action: Action? = nil
    ) {
        let image = VocableListCellAction.systemImage(imageName, symbolConfiguration: symbolConfiguration)
        self.init(image: image,
                  isEnabled: isEnabled,
                  accessibilityIdentifier: accessibilityIdentifier ?? imageName,
                  accessibilityLabel: accessibilityLabel ?? imageName,
                  action: action)
    }

    private static func systemImage(_ imageName: String, symbolConfiguration: UIImage.SymbolConfiguration? = nil) -> UIImage {
        var image = UIImage(systemName: imageName)!
        if let symbolConfiguration = symbolConfiguration {
            image = image.applyingSymbolConfiguration(symbolConfiguration)!
        }
        return image
    }

    private static var defaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 48, weight: .bold)
    }

    private static var trailingDefaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
    }

    static func delete(isEnabled: Bool = true, accessibilityIdentifier: String? = nil, accessibilityLabel: String? = nil, action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "trash",
                              isEnabled: isEnabled,
                              accessibilityIdentifier: accessibilityIdentifier,
                              accessibilityLabel: accessibilityLabel,
                              action: action)
    }

    static func reorderUp(isEnabled: Bool = true, accessibilityIdentifier: String? = nil, accessibilityLabel: String? = nil, action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "chevron.up",
                              isEnabled: isEnabled,
                              accessibilityIdentifier: accessibilityIdentifier,
                              accessibilityLabel: accessibilityLabel,
                              action: action)
    }

    static func reorderDown(isEnabled: Bool = true, accessibilityIdentifier: String? = nil, accessibilityLabel: String? = nil, action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "chevron.down",
                              isEnabled: isEnabled,
                              accessibilityIdentifier: accessibilityIdentifier,
                              accessibilityLabel: accessibilityLabel,
                              action: action)
    }

    static func == (lhs: VocableListCellAction, rhs: VocableListCellAction) -> Bool {
        lhs.isEnabled == rhs.isEnabled &&
        lhs.accessibilityLabel == rhs.accessibilityLabel &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.image.isEqual(rhs.image)
    }
}
