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

    private static func orderedContexts(_ contexts: [VLLoggingContext]) -> [VLLoggingContext] {
        let sorted = contexts.sorted { (lhs, rhs) -> Bool in
            guard let lhsStartDate = lhs.startDate, let rhsStartDate = rhs.startDate else {
                return false
            }
            return lhsStartDate > rhsStartDate
        }
        return sorted
    }

    private static func retrieveContexts() -> [VLLoggingContext] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else {
            return []
        }
        guard let result = try? JSONDecoder().decode([VLLoggingContext].self, from: data) else {
            return []
        }

        return orderedContexts(result)
    }

    func append(_ context: VLLoggingContext) {
        contexts.insert(context, at: 0)
    }

    func clear() {
        contexts = []
    }

    func delete(at offsets: IndexSet) {
        contexts.remove(atOffsets: offsets)
    }

    @Published private(set) var contexts: [VLLoggingContext] = ListenModeDebugStorage.retrieveContexts() {
        didSet {
            let sorted = ListenModeDebugStorage.orderedContexts(contexts)
            let truncated = Array(sorted.suffix(maxHistoryCount))
            guard let data = try? JSONEncoder().encode(truncated) else {
                assertionFailure("Failed to encode data")
                return
            }
            UserDefaults.standard.setValue(data, forKey: defaultsKey)
        }
    }
}
