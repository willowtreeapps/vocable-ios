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

    init(text: String? = nil, image: UIImage?, action: (() -> Void)?, isEnabled: Bool = true) {
        self.text = text
        self.image = image
        self.action = action
        self.isEnabled = isEnabled
    }
}

struct SettingsCellContentConfiguration: UIContentConfiguration, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(attributedText)
    }

    static func == (lhs: SettingsCellContentConfiguration, rhs: SettingsCellContentConfiguration) -> Bool {
        return lhs.attributedText.hashValue == rhs.attributedText.hashValue
    }

    var attributedText: NSAttributedString?
    var accessories: [ActionCellAccessory]
    var disclosureStyle: CellDisclosureStyle

    func makeContentView() -> UIView & UIContentView {
        SettingsCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> SettingsCellContentConfiguration {
        return self
    }

}
