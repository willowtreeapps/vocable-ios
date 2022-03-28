//
//  VocableListContentConfiguration.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

struct VocableListContentConfiguration: UIContentConfiguration, Equatable {

    var actions: [VocableListCellAction]
    var attributedTitle: NSAttributedString
    var isPrimaryActionEnabled: Bool
    var accessory: VocableListCellAccessory?
    var primaryAction: (() -> Void)?

    init(title: String, actions: [VocableListCellAction] = [], accessory: VocableListCellAccessory? = nil, isPrimaryActionEnabled: Bool = true, primaryAction: @escaping () -> Void) {

        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white,
                                                         .font: UIFont.systemFont(ofSize: 22, weight: .bold)]

        let attributedText = NSAttributedString(string: title, attributes: attributes)

        self.init(attributedText: attributedText, actions: actions, accessory: accessory, isPrimaryActionEnabled: isPrimaryActionEnabled, primaryAction: primaryAction)
    }

    init(attributedText: NSAttributedString, actions: [VocableListCellAction] = [], accessory: VocableListCellAccessory? = nil, isPrimaryActionEnabled: Bool = true, primaryAction: @escaping () -> Void) {
        self.attributedTitle = attributedText
        self.isPrimaryActionEnabled = isPrimaryActionEnabled
        self.primaryAction = primaryAction
        self.actions = actions
        self.accessory = accessory
    }

    func makeContentView() -> UIView & UIContentView {
        VocableListCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> VocableListContentConfiguration {
        return self
    }

    static func == (lhs: VocableListContentConfiguration, rhs: VocableListContentConfiguration) -> Bool {
        lhs.actions.elementsEqual(rhs.actions) &&
        lhs.attributedTitle.isEqual(to: rhs.attributedTitle) &&
        lhs.isPrimaryActionEnabled == rhs.isPrimaryActionEnabled &&
        lhs.accessory == rhs.accessory
    }
}
