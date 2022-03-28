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

    private init(image: UIImage, isEnabled: Bool = true, action: Action? = nil) {
        self.image = image
        self.isEnabled = isEnabled
        self.action = action
    }

    private init(systemImage imageName: String, symbolConfiguration: UIImage.SymbolConfiguration? = nil, isEnabled: Bool = true, action: Action? = nil) {
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfiguration)!
        self.image = image
        self.isEnabled = isEnabled
        self.action = action
    }

    private static var defaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 48, weight: .bold)
    }

    private static var trailingDefaultSymbolConfiguration: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
    }

    static func delete(isEnabled: Bool = true, action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "trash", isEnabled: isEnabled, action: action)
    }

    static func reorderUp(isEnabled: Bool = true, action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "chevron.up", isEnabled: isEnabled, action: action)
    }

    static func reorderDown(isEnabled: Bool = true, action: Action?) -> VocableListCellAction {
        VocableListCellAction(systemImage: "chevron.down", isEnabled: isEnabled, action: action)
    }

    static func == (lhs: VocableListCellAction, rhs: VocableListCellAction) -> Bool {
        lhs.isEnabled == rhs.isEnabled &&
        lhs.image.isEqual(rhs.image)
    }
}
