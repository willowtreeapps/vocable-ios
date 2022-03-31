//
//  EditPhraseNameController.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/30/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import CoreData
import UIKit

struct EditPhraseNameController: EditTextDelegate {

    let categoryIdentifier: NSManagedObjectID
    let phraseIdentifier: NSManagedObjectID?
    let context: NSManagedObjectContext

    let initialUtterance: String?

    private var canConfirmEdit: Bool = false
    private var shouldDismiss: Bool = true

    /// Inititalizer
    /// - Parameters:
    ///   - categoryIdentifier: represents the category associated with the phrase
    ///   - phraseIdentifier: if nil, create a new phrase, otherwise edit existing phrase
    ///   - context: the context to fetch, edit, and create the phrase
    init(categoryIdentifier: NSManagedObjectID, phraseIdentifier: NSManagedObjectID? = nil, context: NSManagedObjectContext) {
        self.categoryIdentifier = categoryIdentifier
        self.phraseIdentifier = phraseIdentifier
        self.context = context
        if let phraseIdentifier = phraseIdentifier {
            self.initialUtterance = Phrase.fetchObject(in: context, matching: phraseIdentifier)?.utterance
        } else {
            self.initialUtterance = nil
        }
    }

    mutating func editTextViewController(_ viewController: EditTextViewController, textDidChange text: String?) {
        let textDidChange = initialUtterance != text
        let isTextEmpty = text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true

        canConfirmEdit = textDidChange && !isTextEmpty

        viewController.setNeedsUpdateConfiguration()
    }

    func editTextViewControllerNavigationItems(_ viewController: EditTextViewController) -> EditTextViewController.NavigationConfiguration {
        let currentUtterance = viewController.text
        let textDidChange = initialUtterance != currentUtterance

        let leftItem = EditTextNavigationButton.Configuration.dismissal(for: viewController, textDidChange: textDidChange)

        let rightItem = EditTextNavigationButton.Configuration(image: UIImage(systemName: "checkmark")!, isEnabled: canConfirmEdit) {
            guard let currentUtterance = currentUtterance else { return }
            handleSavingPhrase(with: currentUtterance, in: viewController)
        }

        return EditTextViewController.NavigationConfiguration(leftItem: leftItem, rightItem: rightItem)
    }

    func editTextViewControllerInitialValue(_ viewController: EditTextViewController) -> String? {
        return initialUtterance
    }

    // MARK: - Private Helpers

    private func handleSavingPhrase(with utterance: String?, in viewController: UIViewController) {
        guard let utterance = utterance else {
            return
        }

        let request: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        request.predicate = {
            let isInCategory = Predicate(\Phrase.category, isEqual: categoryIdentifier)
            let isExistingPhrase = Predicate(\Phrase.utterance, like: utterance)
            return isInCategory && isExistingPhrase
        }()
        request.fetchLimit = 1
        let results = (try? context.fetch(request)) ?? []

        if results.isEmpty {
            savePhrase(with: utterance, in: viewController)
        } else {
            presentExistingPhraseAlert(for: viewController) {
                savePhrase(with: utterance, in: viewController)
            }
        }
    }

    private func savePhrase(with utterance: String, in viewController: UIViewController) {
        guard let category = Category.fetchObject(in: context, matching: categoryIdentifier) else {
            return
        }

        context.performAndWait {
            let alertMessage: String
            if let phraseIdentifier = phraseIdentifier, let phrase = Phrase.fetchObject(in: context, matching: phraseIdentifier) {
                editExistingPhrase(phrase, with: utterance)
                alertMessage = NSLocalizedString("category_editor.toast.changes_saved.title",
                                                 comment: "changes to an existing phrase were saved successfully")
            } else {
                _ = Phrase.create(withUserEntry: utterance, category: category, in: context)
                alertMessage = {
                    let format = NSLocalizedString("phrase_editor.toast.successfully_saved_to_favorites.title_format",
                                                   comment: "Saved to user favorites category toast title")
                    return String.localizedStringWithFormat(format, category.name ?? "")
                }()
            }

            do {
                try context.save()
                DispatchQueue.main.async {
                    ToastWindow.shared.presentEphemeralToast(withTitle: alertMessage)
                    viewController.dismiss(animated: true)
                }

            } catch {
                assertionFailure("Failed to save user generated phrase: \(error)")
            }
        }
    }

    private func editExistingPhrase(_ phrase: Phrase, with utterance: String) {
        if phrase.isUserGenerated {
            phrase.utterance = utterance
        } else {
            let textDidChange = utterance != initialUtterance
            phrase.utterance = utterance
            phrase.isUserRenamed = phrase.isUserRenamed || textDidChange
        }
    }

    private func presentExistingPhraseAlert(for viewController: UIViewController, confirmationHandler: @escaping () -> Void) {
        let title = NSLocalizedString("phrase_editor.alert.phrase_name_exists.title",
                                      comment: "Phrase already exists alert title")
        let cancelButtonTitle = NSLocalizedString("phrase_editor.alert.phrase_name_exists.cancel.button",
                                                   comment: "Phrase already exists alert cancel button")
        let createButtonTitle = NSLocalizedString("phrase_editor.alert.phrase_name_exists.create.button",
                                                   comment: "Phrase already exists alert create button")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        alert.addAction(GazeableAlertAction(title: createButtonTitle, style: .destructive, handler: confirmationHandler))
        viewController.present(alert, animated: true)
    }
}
