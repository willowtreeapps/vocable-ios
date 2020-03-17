//
//  NSPersistentContainer+Shared.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/21/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import CoreData

extension NSPersistentContainer {
    private struct Storage {
        static let container: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Phrases")
            container.loadPersistentStores { (_, error) in
                if let error = error {
                    assertionFailure("CoreData: Unresolved error \(error.localizedDescription)")
                    return
                }
                container.viewContext.automaticallyMergesChangesFromParent = true
            }
            return container
        }()
    }

    static var shared: NSPersistentContainer {
        return Storage.container
    }
}
