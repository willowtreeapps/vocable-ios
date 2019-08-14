//
//  CoreDataStack.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    public static var shared: CoreDataStack!
    
    private let persistentContainer: NSPersistentContainer
    
    public let viewContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    public static func loadPersistentContainer(_ name: String) {
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        shared = CoreDataStack(container: container)
    }
    
    internal init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.viewContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let backgroundContext = self.persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return self.persistentContainer.newBackgroundContext()
    }
    
    public func clearUserData() {
        let context = self.newBackgroundContext()
        context.performAndWait {
            let entities = self.persistentContainer.managedObjectModel.entities
            for entity in entities {
                let name = entity.name ?? ""
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                fetchRequest.includesPropertyValues = false
                do {
                    let result = try context.fetch(fetchRequest) as? [NSManagedObject]
                    result?.forEach {
                        context.delete($0)
                        print("Object Deleted")
                    }
                } catch let err {
                    print(err.localizedDescription)
                }
            }
            self.saveContext(with: context)
        }
    }
    
    public func saveContext(with child: NSManagedObjectContext) {
        do {
            try child.save()
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
