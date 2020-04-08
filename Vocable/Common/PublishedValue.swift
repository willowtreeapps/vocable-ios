//
//  PublishedValue.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper struct PublishedValue<T> {
    typealias Publisher = AnyPublisher<T, Never>
    private let subject: CurrentValueSubject<T, Never>
    var wrappedValue: T {
        didSet {
            subject.send(wrappedValue)
        }
    }
    var projectedValue: PublishedValue<T>.Publisher {
        mutating get {
            return subject.eraseToAnyPublisher()
        }
    }
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.subject = CurrentValueSubject<T, Never>(self.wrappedValue)
    }
}
