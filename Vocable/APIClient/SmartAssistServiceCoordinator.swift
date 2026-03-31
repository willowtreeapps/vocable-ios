//
//  SmartAssistServiceCoordinator.swift
//  Vocable
//
//  Created on 3/31/26.
//  Copyright © 2026 WillowTree. All rights reserved.
//

import Foundation

enum SmartAssistServiceType {
    case foundationModels
    case cloudAPI
    case none
}

final class SmartAssistServiceCoordinator {

    // MARK: - Properties

    private let apiClient: ListenAPIClient

    #if canImport(FoundationModels)
    private var foundationModelService: (any SmartAssistService)?
    #endif

    private(set) var activeServiceType: SmartAssistServiceType = .none

    // MARK: - Init

    init(apiClient: ListenAPIClient) {
        self.apiClient = apiClient

        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            self.foundationModelService = FoundationModelService()
        }
        #endif
    }

    // MARK: - Public Methods

    func query(_ prompt: String) async throws -> [String] {
        // Try Foundation Models first
        #if canImport(FoundationModels)
        if #available(iOS 26, *), let fmService = foundationModelService {
            if await fmService.checkAvailability() {
                do {
                    let responses = try await fmService.query(prompt)
                    activeServiceType = .foundationModels
                    return responses
                } catch {
                    // Foundation Models failed; fall through to API
                }
            }
        }
        #endif

        // Fall back to Cloud API
        guard await apiClient.checkAvailability() else {
            activeServiceType = .none
            throw SmartAssistServiceError.unavailable
        }

        let responses = try await apiClient.query(prompt)
        activeServiceType = .cloudAPI
        return responses
    }

    func userResponded(to prompt: String, with response: String) {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            foundationModelService?.userResponded(to: prompt, with: response)
        }
        #endif
        apiClient.userResponded(to: prompt, with: response)
    }

    func resetConversation() {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            foundationModelService?.resetConversation()
        }
        #endif
        apiClient.resetConversation()
    }
}
