//
//  SmartAssistService.swift
//  Vocable
//
//  Created on 3/31/26.
//  Copyright © 2026 WillowTree. All rights reserved.
//

import Foundation

/// A service that produces suggested response phrases for an AAC user
/// given a transcribed speech prompt.
protocol SmartAssistService: AnyObject {
    /// Checks whether this service is currently available.
    func checkAvailability() async -> Bool

    /// Queries the service with a transcribed prompt and returns suggested responses.
    func query(_ prompt: String) async throws -> [String]

    /// Informs the service that the user selected a response, for conversation history tracking.
    func userResponded(to prompt: String, with response: String)

    /// Resets any accumulated conversation history.
    func resetConversation()
}

enum SmartAssistServiceError: Error {
    case unavailable
    case contextWindowExceeded
    case internalError(underlying: Error)
}
