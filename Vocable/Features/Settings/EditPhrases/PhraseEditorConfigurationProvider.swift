//
//  PhraseEditorConfigurationProvider.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/30/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import CoreData
import UIKit

struct PhraseEditorConfigurationProvider: TextEditorConfigurationProviding {

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

    mutating func textEditorViewController(_ viewController: TextEditorViewController, textDidChange text: String?) {
        let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let textDidChange = initialUtterance != trimmedText
        let isTextEmpty = trimmedText?.isEmpty ?? true

        canConfirmEdit = textDidChange && !isTextEmpty

        viewController.setNeedsUpdateConfiguration()
    }

    func textEditorViewControllerConfiguration(_ viewController: TextEditorViewController) -> TextEditorViewController.Configuration {
        let currentUtterance = viewController.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let textDidChange = initialUtterance != currentUtterance

        let leftConfiguration = TextEditorNavigationButton.Configuration.dismissal(for: viewController, textDidChange: textDidChange)

        let rightConfiguration = TextEditorNavigationButton.Configuration.save(isEnabled: canConfirmEdit) { [weak viewController] in
            guard let currentUtterance = currentUtterance,
                  let viewController = viewController else { return }
            handleSavingPhrase(with: currentUtterance, in: viewController)
        }

        return TextEditorViewController.Configuration(leftItemConfiguraton: leftConfiguration, rightItemConfiguration: rightConfiguration)
    }

    func textEditorViewControllerInitialValue(_ viewController: TextEditorViewController) -> String? {
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
            let isNotUserRemoved = !Predicate(\Phrase.isUserRemoved)
            return isInCategory && isExistingPhrase && isNotUserRemoved
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
                alertMessage = String(localized: "category_editor.toast.changes_saved.title")
            } else {
                _ = Phrase.create(withUserEntry: utterance, category: category, in: context)
                alertMessage = {
                    let format = String(localized: "phrase_editor.toast.successfully_saved_to_favorites.title_format")
                    return String.localizedStringWithFormat(format, category.name ?? "")
                }()
                Analytics.shared.track(.phraseSaved())
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
        let title = String(localized: "phrase_editor.alert.phrase_name_exists.title")
        let cancelButtonTitle = String(localized: "phrase_editor.alert.phrase_name_exists.cancel.button")
        let createButtonTitle = String(localized: "phrase_editor.alert.phrase_name_exists.create.button")

        let alert = GazeableAlertViewController(alertTitle: title)
        alert.addAction(GazeableAlertAction(title: cancelButtonTitle))
        alert.addAction(GazeableAlertAction(title: createButtonTitle, style: .destructive, handler: confirmationHandler))
        viewController.present(alert, animated: true)
    }
}
