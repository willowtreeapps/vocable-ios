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
    
    static let categoryValueSubject = CurrentValueSubject<CategoryViewModel, Never>(initialSelectedCategory)
    private static var initialSelectedCategory: CategoryViewModel =
        Category.fetchAll(in: NSPersistentContainer.shared.viewContext,
                          sortDescriptors: [NSSortDescriptor(keyPath: \Category.identifier, ascending: true)])
        .compactMap { CategoryViewModel($0) }.first!
    
    static let phraseValueSubject = CurrentValueSubject<PhraseViewModel?, Never>(nil)
    
    static let presetsPageIndicatorPublisher = PassthroughSubject<String, Never>()
    static var presetsPageIndicatorText: String = "" {
        didSet {
            presetsPageIndicatorPublisher.send(presetsPageIndicatorText)
        }
    }
}
