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
            handleSavingCategory(with: currentName, in: viewController)
        }

        return EditTextViewController.NavigationConfiguration(leftItem: leftItem, rightItem: rightItem)
    }

    func editTextViewControllerInitialValue(_ viewController: EditTextViewController) -> String? {
        return initialName
    }

    // MARK: - Private Helpers

    private func handleSavingCategory(with name: String?, in viewController: UIViewController) {
        guard let category = Category.fetchObject(in: context, matching: categoryIdentifier),
              let name = name else {
            return
        }

        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = Predicate(\Category.name, like: name)
        request.fetchLimit = 1
        let results = (try? context.fetch(request)) ?? []

        if results.isEmpty {
            saveCategory(for: category, with: name, in: viewController)
        } else {
            presentExistingCategoryAlert(for: viewController) {
                saveCategory(for: category, with: name, in: viewController)
            }
        }
    }

    private func saveCategory(for category: Category, with name: String, in viewController: UIViewController) {
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

    private func presentExistingCategoryAlert(for viewController: UIViewController, confirmationHandler: @escaping () -> Void) {
        let title = NSLocalizedString("text_editor.alert.category_name_exists.title",
                                      comment: "Category already exists alert title")
        let cancelButtonTitle = NSLocalizedString("text_editor.alert.category_name_exists.cancel.button",
                                                   comment: "Category already exists alert cancel button")
        let createButtonTitle = NSLocalizedString("text_editor.alert.category_name_exists.create.button",
                                                   comment: "Category already exists alert create button")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        alert.addAction(GazeableAlertAction(title: createButtonTitle, style: .destructive, handler: confirmationHandler))
        viewController.present(alert, animated: true)
    }
}
