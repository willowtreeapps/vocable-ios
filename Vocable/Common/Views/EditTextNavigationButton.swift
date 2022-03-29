//
//  EditTextNavigationButton.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

final class EditTextNavigationButton: GazeableButton {

    struct Configuration {
        let image: UIImage
        var isEnabled: Bool
        var action: () -> Void
    }

    func configure(with configuration: Configuration?) {
        guard let configuration = configuration else { return }
        setImage(configuration.image, for: .normal)
        isEnabled = configuration.isEnabled

        enumerateEventHandlers { action, _, event, _ in
            if let action = action {
                removeAction(action, for: event)
            }
        }
        addAction(UIAction(handler: { _ in configuration.action() }), for: .primaryActionTriggered)
    }
}
