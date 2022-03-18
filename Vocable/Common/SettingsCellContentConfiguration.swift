//
//  SettingsCellContentConfiguration.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

enum CellDisclosureStyle: Equatable {
    case none
    case disclosure
    case link
    case toggle(Bool)
}

struct ActionCellAccessory: Equatable {

    let image: UIImage
    let action: (() -> Void)?
    let isEnabled: Bool

    init(image: UIImage, isEnabled: Bool = true, action: (() -> Void)?) {
        self.image = image
        self.isEnabled = isEnabled
        self.action = action
    }

    static func == (lhs: ActionCellAccessory, rhs: ActionCellAccessory) -> Bool {
        return lhs.isEnabled == rhs.isEnabled && lhs.image.isEqual(rhs.image)
    }
}

struct SettingsCellContentConfiguration: UIContentConfiguration, Equatable {

    var attributedText: NSAttributedString
    var accessories: [ActionCellAccessory]
    var disclosureStyle: CellDisclosureStyle

    var cellAction: () -> Void

    init(attributedText: NSAttributedString, accessories: [ActionCellAccessory] = [], disclosureStyle: CellDisclosureStyle = .none, cellAction: @escaping () -> Void) {
        self.attributedText = attributedText
        self.accessories = accessories
        self.disclosureStyle = disclosureStyle
        self.cellAction = cellAction
    }

    func makeContentView() -> UIView & UIContentView {
        SettingsCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> SettingsCellContentConfiguration {
        return self
    }

    static func == (lhs: SettingsCellContentConfiguration, rhs: SettingsCellContentConfiguration) -> Bool {
        return lhs.attributedText.isEqual(to: rhs.attributedText) && lhs.accessories.elementsEqual(rhs.accessories)  && lhs.disclosureStyle == rhs.disclosureStyle
    }
}
