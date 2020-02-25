//
//  NSManagedObject+Helpers.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/21/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import CoreData

protocol NSManagedObjectIdentifiable {
    associatedtype IdentifierType
}

extension NSManagedObjectIdentifiable where Self: NSManagedObject {

    static func fetchObject(in context: NSManagedObjectContext, matching identifier: IdentifierType) -> Self? {
        guard let entityName = self.entity().name else {
            return nil
        }
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        if let identifier = identifier as? String {
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        } else {
            fetchRequest.predicate = NSPredicate(format: "identifier == \(identifier)")
        }
        let result = (try? context.fetch(fetchRequest))?.first
        return result
    }
    
    static func fetchAll(in context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor]? = nil) -> [Self] {
        guard let entityName = self.entity().name else {
            return []
        }
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.sortDescriptors = sortDescriptors
        return (try? context.fetch(fetchRequest)) ?? []
    }

    static func fetchOrCreate(in context: NSManagedObjectContext, matching identifier: IdentifierType) -> Self {
        if let existingObject = self.fetchObject(in: context, matching: identifier) {
            return existingObject
        }
        let newObject = self.init(context: context)
        newObject.setValue(identifier, forKeyPath: "identifier")
        return newObject
    }
}

extension NSComparisonPredicate {
    convenience init<A, B>(_ lhsKeyPath: KeyPath<A, B>, _ operationType: Operator, _ rhsValue: B) {
        let lhs = NSExpression(forKeyPath: lhsKeyPath)
        let rhs = NSExpression(forConstantValue: rhsValue)
        self.init(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: operationType)
    }
}
