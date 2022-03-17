//
//  AppResetController.swift
//  Vocable
//
//  Created by Chris Stroud on 3/17/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import CoreData

struct AppResetController {

    private enum ResetError: String, Error {
        case unexpectedFetchResult
    }

    private let persistentContainer: NSPersistentContainer
    private let userDefaults: UserDefaults

    init(persistentContainer: NSPersistentContainer = .shared, userDefaults: UserDefaults = .standard) {
        self.persistentContainer = persistentContainer
        self.userDefaults = userDefaults
    }

    func performReset() -> Bool {

        guard resetUserDefaults() else {
            return false
        }

        guard resetPersistentStore() else {
            return false
        }
        
        return true
    }

    // MARK: UserDefaults

    private func resetUserDefaults() -> Bool {
        let allEntries = userDefaults.dictionaryRepresentation()
        let allKeys = allEntries.keys
        allKeys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
        return true
    }

    // MARK: Persistent Store

    private func resetPersistentStore() -> Bool {
        do {
            let context = persistentContainer.newBackgroundContext()
            try deleteAllEntities(ofType: Phrase.self, in: context)
            try deleteAllEntities(ofType: Category.self, in: context)
            try context.save()
            return true
        } catch {
            assertionFailure("Failed to reset persistent store: \(error)")
            return false
        }
    }

    private func deleteAllEntities<T: NSManagedObject>(ofType: T.Type, in context: NSManagedObjectContext) throws {
        let fetchRequest = T.fetchRequest()
        let allEntities = try context.fetch(fetchRequest)
        try allEntities.forEach { entity in
            guard let managedObject = entity as? NSManagedObject else {
                throw ResetError.unexpectedFetchResult
            }
            context.delete(managedObject)
        }
    }
}
