//
//  PublishedDefault.swift
//  Vocable
//
//  Created by Chris Stroud on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine

/// Adds a `Publisher` and `UserDefaults` persistence to a `Codable` property.
///
/// Properties annotated with `@PublishedDefault` contain both the persisted value corresponding to the provided `UserDefaults` key and a publisher which sends any changes to that value after the property value has been sent. New subscribers will receive the current value of the property first.
@propertyWrapper struct PublishedDefault<T: Codable> {

    private let defaultsKey: String
    private let subject: CurrentValueSubject<T, Never>

    var wrappedValue: T {
        didSet {
            guard let encoded = try? JSONEncoder().encode(wrappedValue) else {
                UserDefaults.standard.removeObject(forKey: defaultsKey)
                return
            }
            UserDefaults.standard.set(encoded, forKey: defaultsKey)
            subject.send(wrappedValue)
        }
    }

    var projectedValue: AnyPublisher<T, Never> {
        mutating get {
            return subject.eraseToAnyPublisher()
        }
    }

    /// Creates a new `PublishedDefault` for the given `UserDefaults` key and default value
    /// - Parameters:
    ///   - key: The key with which the value should be stored in `UserDefaults`
    ///   - defaultValue: The value that should be provided when no value is stored in `UserDefaults`
    init(key: String, defaultValue: T) {
        self.defaultsKey = key
        self.wrappedValue = PublishedDefault.currentDefaultsValue(for: key) ?? defaultValue
        self.subject = CurrentValueSubject<T, Never>(self.wrappedValue)
    }

    private static func currentDefaultsValue(for key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key) {
            if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                return decoded
            }
        }
        return nil
    }
}
