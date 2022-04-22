//
//  PublishedDefault.swift
//  Vocable AAC
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
    private var defaultsCancellable: AnyCancellable?

    var wrappedValue: T {
        get {
            return subject.value
        }
        set {
            PublishedDefault.encodeDefaultsValue(newValue, for: defaultsKey)
            subject.send(wrappedValue)
        }
    }

    var projectedValue: CurrentValueSubject<T, Never> {
        mutating get {
            return subject
        }
    }

    /// Creates a new `PublishedDefault` for the given `UserDefaults` key and default value
    /// - Parameters:
    ///   - key: The key with which the value should be stored in `UserDefaults`
    ///   - defaultValue: The value that should be provided when no value is stored in `UserDefaults`
    init(key: UserDefaultsKey, defaultValue: T) {
        self.defaultsKey = key.value
        let value = PublishedDefault.currentDefaultsValue(for: key) ?? defaultValue
        let subject = CurrentValueSubject<T, Never>(value)
        self.subject = subject
        self.defaultsCancellable = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .compactMap { _ in
                PublishedDefault.currentDefaultsValue(for: key)
            }.sink { value in
                subject.send(value)
            }
    }

    private static func currentDefaultsValue(for key: UserDefaultsKey) -> T? {

        if let object = UserDefaults.standard.object(forKey: key.value) as? T {
            return object
        }

        if let data = UserDefaults.standard.data(forKey: key.value) {
            if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                return decoded
            }
        }
        return nil
    }

    private static func encodeDefaultsValue(_ value: T?, for key: String) {
        guard let value = value else {
            UserDefaults.standard.removeObject(forKey: key)
            return
        }

        if let value = value as? Bool {
            UserDefaults.standard.set(value, forKey: key)
        } else if let value = value as? Int {
            UserDefaults.standard.set(value, forKey: key)
        } else if let value = value as? Double {
            UserDefaults.standard.set(value, forKey: key)
        } else if let value = value as? Float {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            guard let encoded = try? JSONEncoder().encode(value) else {
                UserDefaults.standard.removeObject(forKey: key)
                return
            }
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

extension PublishedDefault {

    typealias Key = UserDefaultsKey
}

struct UserDefaultsKey: ExpressibleByStringLiteral {

    let value: String

    init(stringLiteral value: StringLiteralType) {
        self.value = value
    }
}

extension UserDefaultsKey {

    static let isListeningModeEnabled: UserDefaultsKey = "isListeningModeEnabled"
    static let isHotWordPermitted: UserDefaultsKey = "isHotWordPermitted"
    static let sensitivitySetting: UserDefaultsKey = "sensitivitySetting"
    static let dwellDuration: UserDefaultsKey = "dwellDuration"
    static let isHeadTrackingEnabled: UserDefaultsKey = "isHeadTrackingEnabled"
    static let listeningModeFeatureFlagEnabled: UserDefaultsKey = "listeningModeFeatureFlagEnabled"
}
