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
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel
    }

    private init(
        systemImage imageName: String,
        symbolConfiguration: UIImage.SymbolConfiguration? = nil,
        isEnabled: Bool = true,
        accessibilityIdentifier: String? = nil,
        accessibilityLabel: String? = nil,
        action: Action? = nil
    ) {
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfiguration)!
        self.init(image: image,
                  isEnabled: isEnabled,
                  accessibilityIdentifier: accessibilityIdentifier ?? imageName,
                  action: action)
    }

    private static var defaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 48, weight: .bold)
    }

    private static var trailingDefaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
    }

    static func delete(isEnabled: Bool = true,
                       accessibilityIdentifier: String = AccessibilityID.settings.editPhrases.deletePhraseButton.id,
                       accessibilityLabel: String = "delete",
                       action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "trash",
                              isEnabled: isEnabled,
                              accessibilityIdentifier: accessibilityIdentifier,
                              accessibilityLabel: accessibilityLabel,
                              action: action)
    }

    static func reorderUp(isEnabled: Bool = true, accessibilityIdentifier: String = "reorder.upButton", accessibilityLabel: String = "reorder up", action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "chevron.up",
                              isEnabled: isEnabled,
                              accessibilityIdentifier: accessibilityIdentifier,
                              accessibilityLabel: accessibilityLabel,
                              action: action)
    }

    static func reorderDown(isEnabled: Bool = true, accessibilityIdentifier: String = "reorder.downButton", accessibilityLabel: String = "reorder down", action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "chevron.down",
                              isEnabled: isEnabled,
                              accessibilityIdentifier: accessibilityIdentifier,
                              accessibilityLabel: accessibilityLabel,
                              action: action)
    }

    static func == (lhs: VocableListCellAction, rhs: VocableListCellAction) -> Bool {
        lhs.isEnabled == rhs.isEnabled &&
        lhs.accessibilityIdentifier == rhs.accessibilityIdentifier &&
        lhs.image.isEqual(rhs.image)
    }
}
