//
//  EditCategoryNameController.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/30/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import CoreData
import UIKit

struct EditCategoryNameController: EditTextDelegate {

    let categoryIdentifier: String
    let context: NSManagedObjectContext

    let initialName: String?

    private var canConfirmEdit: Bool = false
    private var shouldDismiss: Bool = true

    init(categoryIdentifier: String, context: NSManagedObjectContext) {
        self.categoryIdentifier = categoryIdentifier
        self.context = context
        self.initialName = Category.fetchObject(in: context, matching: categoryIdentifier)?.name
    }

    mutating func editTextViewController(_ viewController: EditTextViewController, textDidChange text: String?) {
        let textDidChange = initialName != text
        let isTextEmpty = text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true

        canConfirmEdit = textDidChange && !isTextEmpty

        viewController.setNeedsUpdateConfiguration()
    }

    func editTextViewControllerNavigationItems(_ viewController: EditTextViewController) -> EditTextViewController.NavigationConfiguration {
        let currentName = viewController.text
        let textDidChange = initialName != currentName

        let leftItem = EditTextNavigationButton.Configuration.dismissal(for: viewController, textDidChange: textDidChange)

        let rightItem = EditTextNavigationButton.Configuration(image: UIImage(systemName: "checkmark")!, isEnabled: canConfirmEdit) {
            guard let currentName = currentName else { return }
            saveCategory(with: currentName, for: viewController)
        }

        return EditTextViewController.NavigationConfiguration(leftItem: leftItem, rightItem: rightItem)
    }

    func editTextViewControllerInitialValue(_ viewController: EditTextViewController) -> String? {
        return initialName
    }

    // MARK: - Private Helpers

    private func saveCategory(with name: String?, for viewController: UIViewController) {
        guard let category = Category.fetchObject(in: context, matching: categoryIdentifier),
              let name = name else {
            return
        }

        let categories = Category.fetchAll(in: context)
        guard !categories.contains(where: { $0.name == name }) else {
            presentExistingCategoryAlert(for: viewController)
            return
        }

        let textDidChange = (name != initialName)
        category.name = name
        category.isUserRenamed = category.isUserRenamed || textDidChange

        do {
            try Category.updateAllOrdinalValues(in: context)
            try context.save()

            let alertMessage = NSLocalizedString("category_editor.toast.successfully_saved.title",
                                                 comment: "User edited name of the category and saved it successfully")

            ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
        } catch {
            assertionFailure("Failed to save category: \(error)")
        }
        viewController.dismiss(animated: true)
    }

    private func presentExistingCategoryAlert(for viewController: UIViewController) {
        // TODO: Find out final design, should be a soft alert allowing confirmation to edit
        let title = NSLocalizedString("text_editor.alert.category_name_exists.title",
                                      comment: "Category already exists alert title")
        let okButtonTitle = NSLocalizedString("text_editor.alert.category_name_exists.button",
                                                   comment: "Dismiss alert action title")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: okButtonTitle))
        viewController.present(alert, animated: true)
    }
}
