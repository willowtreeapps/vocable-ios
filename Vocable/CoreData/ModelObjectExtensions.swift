//
//  ModelObjectExtensions.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/21/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

extension Category: NSManagedObjectIdentifiable {
    typealias IdentifierType = String

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: #keyPath(creationDate))
        setPrimitiveValue(false, forKey: #keyPath(isUserGenerated))
    }
}

extension Phrase: NSManagedObjectIdentifiable {
    typealias IdentifierType = String

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: #keyPath(creationDate))
        setPrimitiveValue(false, forKey: #keyPath(isUserGenerated))
    }
}
