//
//  ListenModeDebugStorage.swift
//  Vocable
//
//  Created by Chris Stroud on 3/19/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import Foundation
import VocableListenCore

final class ListenModeDebugStorage: ObservableObject {

    static let shared = ListenModeDebugStorage()

    private init() {

    }

    private let maxHistoryCount = 50
    private static let defaultsKey = "loggingContextHistory"
    private var defaultsKey: String {
        return ListenModeDebugStorage.defaultsKey
    }

    private static func retrieveContexts() -> [VLLoggingContext] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else {
            return []
        }
        guard let result = try? JSONDecoder().decode([VLLoggingContext].self, from: data) else {
            return []
        }
        return result
    }

    @Published var contexts: [VLLoggingContext] = ListenModeDebugStorage.retrieveContexts() {
        didSet {
            let truncated = Array(contexts.suffix(maxHistoryCount))
            guard let data = try? JSONEncoder().encode(truncated) else {
                assertionFailure("Failed to encode data")
                return
            }
            UserDefaults.standard.setValue(data, forKey: defaultsKey)
        }
    }
}
