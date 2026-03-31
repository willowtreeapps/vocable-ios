//
//  FoundationModelService.swift
//  Vocable
//
//  Created on 3/31/26.
//  Copyright © 2026 WillowTree. All rights reserved.
//

#if canImport(FoundationModels)
import Foundation
import FoundationModels

@available(iOS 26, *)
final class FoundationModelService: SmartAssistService {

    // MARK: - Properties

    private let model = SystemLanguageModel.default
    private var session: LanguageModelSession?
    private var turnCount = 0
    private var lastUserResponse: (prompt: String, response: String)?

    /// Proactively reset the session after this many turns to avoid context window exhaustion.
    private let maxTurnsBeforeReset = 8

    private static let instructions = """
        You are an assistant for an AAC (Augmentative and Alternative Communication) app. \
        A person nearby is speaking to the user. The user cannot speak verbally and will \
        select one of the responses you suggest.

        Given what was said, suggest 3 to 5 short, natural responses the user might want \
        to say. Keep responses concise (under 10 words each). Include a mix of: \
        direct answers to questions, conversational acknowledgments, and follow-up questions \
        when appropriate.
        """

    // MARK: - SmartAssistService

    func checkAvailability() async -> Bool {
        guard model.isAvailable else {
            return false
        }
        return model.supportsLocale()
    }

    func query(_ prompt: String) async throws -> [String] {
        // Reset session proactively if we've had many turns
        if turnCount >= maxTurnsBeforeReset {
            resetConversation()
        }

        let session = getOrCreateSession()

        // Build the prompt with conversation context
        let fullPrompt: String
        if let lastUserResponse {
            fullPrompt = "The user selected the response: \"\(lastUserResponse.response)\". Now someone said: \"\(prompt)\""
            self.lastUserResponse = nil
        } else {
            fullPrompt = "Someone said: \"\(prompt)\""
        }

        do {
            let response = try await session.respond(
                to: fullPrompt,
                generating: SmartAssistResponse.self
            )
            turnCount += 1
            return response.content.responses
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .exceededContextWindowSize:
                // Reset and retry once
                resetConversation()
                let freshSession = getOrCreateSession()
                let retryResponse = try await freshSession.respond(
                    to: "Someone said: \"\(prompt)\"",
                    generating: SmartAssistResponse.self
                )
                turnCount = 1
                return retryResponse.content.responses
            default:
                throw SmartAssistServiceError.internalError(underlying: error)
            }
        }
    }

    func userResponded(to prompt: String, with response: String) {
        lastUserResponse = (prompt: prompt, response: response)
    }

    func resetConversation() {
        session = nil
        turnCount = 0
        lastUserResponse = nil
    }

    // MARK: - Private

    private func getOrCreateSession() -> LanguageModelSession {
        if let session {
            return session
        }
        let newSession = LanguageModelSession(instructions: Self.instructions)
        self.session = newSession
        return newSession
    }
}
#endif
