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
        let title = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.title",
                                      comment: "Exit edit sayings alert title")
        let discardButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.discard.title",
                                                   comment: "Discard changes alert action title")
        let continueButtonTitle = NSLocalizedString("text_editor.alert.cancel_editing_confirmation.button.continue_editing.title",
                                                    comment: "Continue editing alert action title")
        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: continueButtonTitle))
        alert.addAction(GazeableAlertAction(title: discardButtonTitle, style: .destructive, handler: onDiscardCompletion))
        return alert
    }
}

final class EditTextNavigationButton: GazeableButton {

    struct Configuration {
        let image: UIImage
        var isEnabled: Bool
        var action: () -> Void

        static func dismissal(for viewController: UIViewController, textDidChange: Bool = false) -> Self {
            return Configuration(image: UIImage(systemName: "xmark.circle")!, isEnabled: true) {
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
