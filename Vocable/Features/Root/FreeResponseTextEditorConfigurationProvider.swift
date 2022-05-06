//
//  FreeResponseTextEditorConfigurationProvider.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/31/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import CoreData
import UIKit

final class FreeResponseTextEditorConfigurationProvider: TextEditorConfigurationProviding {

    let context: NSManagedObjectContext

    private var favoritedPhraseIdentifier: NSManagedObjectID?

    private var needsUpdateFavoritesState = true

    private var canFavoritePhrase: Bool = false
    private var isFavorited: Bool { favoritedPhraseIdentifier != nil }
    private var shouldDismiss: Bool = true

    private let initialUtterance = ""

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func textEditorViewController(_ viewController: TextEditorViewController, textDidChange text: String?) {
        needsUpdateFavoritesState = true
        viewController.setNeedsUpdateConfiguration()
    }

    func textEditorViewControllerConfiguration(_ viewController: TextEditorViewController) -> TextEditorViewController.Configuration {
        let currentUtterance = viewController.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if needsUpdateFavoritesState {
            updateFavoriteState(for: currentUtterance)
        }

        let leftConfiguration = TextEditorNavigationButton.Configuration.dismissal(for: viewController)

        let rightConfiguration = TextEditorNavigationButton.Configuration.favorite(isFavorited: isFavorited, isEnabled: canFavoritePhrase) { [weak self, weak viewController] in
            guard let currentUtterance = currentUtterance,
                  let viewController = viewController else { return }
            self?.favoritePhrase(with: currentUtterance, in: viewController)
        }

        return TextEditorViewController.Configuration(leftItemConfiguraton: leftConfiguration, rightItemConfiguration: rightConfiguration)
    }

    func textEditorViewControllerInitialValue(_ viewController: TextEditorViewController) -> String? {
        return initialUtterance
    }

    private func updateFavoriteState(for text: String?) {
        guard let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            favoritedPhraseIdentifier = nil
            canFavoritePhrase = false
            return
        }

        let context = NSPersistentContainer.shared.viewContext
        canFavoritePhrase = true
        do {
            let userFavorites = try Category.fetch(.userFavorites, in: context)

            var predicate = Predicate(\Phrase.category, equalTo: userFavorites)
            predicate &= Predicate(\Phrase.isUserGenerated)
            predicate &= Predicate(\Phrase.utterance, equalTo: text)

            let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
            fetchRequest.predicate = predicate
            fetchRequest.fetchLimit = 1
            let results = try context.fetch(fetchRequest)
            favoritedPhraseIdentifier = results.first?.objectID
            needsUpdateFavoritesState = false
        } catch {
            print("Failed to update favorites state: \(error)")
        }
    }

    // MARK: - Private Helpers

    private func favoritePhrase(with utterance: String?, in viewController: TextEditorViewController) {
        guard let utterance = utterance else {
            return
        }

        context.performAndWait {
            do {

                if let favoritedPhraseIdentifier = favoritedPhraseIdentifier,
                   let favoritedPhrase = Phrase.fetchObject(in: context, matching: favoritedPhraseIdentifier) {
                    context.delete(favoritedPhrase)
                } else {
                    _ = try Phrase.create(withUserEntry: utterance, in: context)
                    Analytics.shared.track(.phraseFavorited())
                }

                try context.save()
            } catch {
                print("Could not save: \(error)")
            }
        }
        needsUpdateFavoritesState = true
        viewController.setNeedsUpdateConfiguration()
    }
}
