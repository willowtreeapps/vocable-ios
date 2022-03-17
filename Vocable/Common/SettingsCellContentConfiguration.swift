//
//  SettingsCellContentConfiguration.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

enum CellDisclosureStyle {
    case none
    case disclosure
    case link
    case toggle(Bool)
}

struct ActionCellAccessory {
    let text: String?
    let image: UIImage?
    let action: (() -> Void)?
    let isEnabled: Bool

    init(text: String? = nil, image: UIImage?, isEnabled: Bool = true, action: (() -> Void)?) {
        self.text = text
        self.image = image
        self.isEnabled = isEnabled
        self.action = action
    }
}

struct SettingsCellContentConfiguration: UIContentConfiguration {

    var attributedText: NSAttributedString?
    var accessories: [ActionCellAccessory]
    var disclosureStyle: CellDisclosureStyle

    var cellAction: () -> Void

    init(attributedText: NSAttributedString?, accessories: [ActionCellAccessory] = [], disclosureStyle: CellDisclosureStyle = .none, cellAction: @escaping () -> Void) {
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
}
