//
//  EditTextNavigationButton.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

private extension GazeableAlertViewController {
    static func discardChangesAlert(onDiscardCompletion: @escaping () -> Void) -> GazeableAlertViewController {
        let title = String(localized: "text_editor.alert.cancel_editing_confirmation.title")
        let discardButtonTitle = String(localized: "text_editor.alert.cancel_editing_confirmation.button.discard.title")
        let continueButtonTitle = String(localized: "text_editor.alert.cancel_editing_confirmation.button.continue_editing.title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(.continueEditing(withTitle: continueButtonTitle))
        alert.addAction(.discardChanges(withTitle: discardButtonTitle, handler: onDiscardCompletion))
        return alert
    }
}

final class TextEditorNavigationButton: GazeableButton {

    typealias Action = () -> Void

    struct Configuration {
        let image: UIImage
        var isEnabled: Bool
        let accessibilityIdentifier: String?
        var action: Action?

        static func dismissal(for viewController: UIViewController, isEnabled: Bool = true, textDidChange: Bool = false, accessibilityIdentifier: String = "keyboard.dismissButton") -> Self {
            Configuration(image: UIImage(systemName: "xmark.circle")!, isEnabled: isEnabled, accessibilityIdentifier: accessibilityIdentifier) { [weak viewController] in
                guard let viewController = viewController else { return }
                if textDidChange {
                    let alert = GazeableAlertViewController.discardChangesAlert {
                        viewController.dismiss(animated: true)
                    }
                    viewController.present(alert, animated: true)
                } else {
                    viewController.dismiss(animated: true, completion: nil)
                }
            }
        }

        static func save(isEnabled: Bool = false, accessibilityIdentifier: String = "keyboard.saveButton", action: @escaping Action) -> Self {
            Configuration(image: UIImage(systemName: "checkmark")!,
                          isEnabled: isEnabled,
                          accessibilityIdentifier: accessibilityIdentifier,
                          action: action)
        }

        static func favorite(isFavorited: Bool, isEnabled: Bool = false, accessibilityIdentifier: String = "keyboard.favoriteButton", action: @escaping Action) -> Self {
            Configuration(image: isFavorited ? UIImage(systemName: "star.fill")! : UIImage(systemName: "star")!,
                          isEnabled: isEnabled,
                          accessibilityIdentifier: accessibilityIdentifier,
                          action: action)
        }
    }

    func configure(with configuration: Configuration?) {
        guard let configuration = configuration else { return }
        setImage(configuration.image, for: .normal)
        isEnabled = configuration.isEnabled
        accessibilityIdentifier = configuration.accessibilityIdentifier

        enumerateEventHandlers { action, _, event, _ in
            if let action = action {
                removeAction(action, for: event)
            }
        }
        if let action = configuration.action {
            addAction(UIAction(handler: { _ in action() }), for: .primaryActionTriggered)
        }
    }
}
