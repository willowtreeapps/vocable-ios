//
//  PublishedDefault.swift
//  Vocable
//
//  Created by Chris Stroud on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct PublishedDefault<T: Codable> {

    private let defaultsKey: String
    private let subject = PassthroughSubject<T, Never>()

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

    init(key: String, defaultValue: T) {
        self.defaultsKey = key
        self.wrappedValue = PublishedDefault.currentDefaultsValue(for: key) ?? defaultValue
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
