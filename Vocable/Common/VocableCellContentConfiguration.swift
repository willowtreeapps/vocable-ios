//
//  SettingsCellContentConfiguration.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

extension VocableListCellContentView.Configuration {
    struct TrailingAccessory: Equatable {

        let customView: UIView

        private static func systemImage(_ imageName: String) -> TrailingAccessory {
            TrailingAccessory(customView: UIImageView(image: UIImage(systemName: imageName)?.applyingSymbolConfiguration(.init(pointSize: 36, weight: .bold))))
        }

        static var disclosureIndicator: TrailingAccessory { .systemImage("chevron.right") }
    }
}

extension VocableListCellContentView.Configuration {

    struct AccessoryAction: Equatable {

        let image: UIImage
        let action: (() -> Void)?
        let isEnabled: Bool

        init(image: UIImage, isEnabled: Bool = true, action: (() -> Void)?) {
            self.image = image
            self.isEnabled = isEnabled
            self.action = action
        }

        static func == (lhs: AccessoryAction, rhs: AccessoryAction) -> Bool {
            return lhs.isEnabled == rhs.isEnabled && lhs.image.isEqual(rhs.image)
        }
    }

    struct PrimaryAction: Equatable {

        let image: UIImage
        let action: (() -> Void)?
        let isEnabled: Bool

        init(image: UIImage, isEnabled: Bool = true, action: (() -> Void)?) {
            self.image = image
            self.isEnabled = isEnabled
            self.action = action
        }

        static func == (lhs: PrimaryAction, rhs: PrimaryAction) -> Bool {
            return lhs.isEnabled == rhs.isEnabled && lhs.image.isEqual(rhs.image)
        }
    }
}

extension VocableListCellContentView {

    struct Configuration: UIContentConfiguration, Equatable {

        var attributedText: NSAttributedString
        var accessories: [AccessoryAction]
        var trailingAccessory: TrailingAccessory?

        var primaryAction: () -> Void

        init(attributedText: NSAttributedString, accessories: [AccessoryAction] = [], trailingAccessory: TrailingAccessory? = nil, primaryAction: @escaping () -> Void) {
            self.attributedText = attributedText
            self.accessories = accessories
            self.trailingAccessory = trailingAccessory
            self.primaryAction = primaryAction
        }

        func makeContentView() -> UIView & UIContentView {
            VocableListCellContentView(configuration: self)
        }

        func updated(for state: UIConfigurationState) -> VocableListCellContentView.Configuration {
            return self
        }

        static func == (lhs: VocableListCellContentView.Configuration, rhs: VocableListCellContentView.Configuration) -> Bool {
            return lhs.attributedText.isEqual(to: rhs.attributedText) && lhs.accessories.elementsEqual(rhs.accessories) && lhs.trailingAccessory == rhs.trailingAccessory
        }
    }
}
