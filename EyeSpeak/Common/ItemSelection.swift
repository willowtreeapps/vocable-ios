//
//  ItemSelection.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine
import CoreData

struct ItemSelection {
    
    static var categoryPublisher = PassthroughSubject<CategoryViewModel, Never>()
    static var selectedCategory: CategoryViewModel =
        Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                          sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
        .compactMap { CategoryViewModel($0) }.first! {
        didSet {
            categoryPublisher.send(selectedCategory)
        }
    }
    
    static var phrasePublisher = PassthroughSubject<PhraseViewModel?, Never>()
    static var selectedPhrase: PhraseViewModel? {
        didSet {
            phrasePublisher.send(selectedPhrase)
        }
    }
}
