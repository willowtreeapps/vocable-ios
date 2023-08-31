//
//  ListenAPIClient.swift
//  Vocable
//
//  Created by Andrew Carter on 7/2/23.
//  Copyright © 2023 WillowTree. All rights reserved.
//

import Foundation
import UIKit

enum ListenAPIClientError: Error {
    /// Occurs when we're unable to form a URL for the API
    case failedToMakeURLRequest
    
    /// Occurs when the response from the API is:
    ///     - Not an HTTP response
    ///     - Not a 200 status code
    ///     - Not a status code handled by a more specific error
    case invalidResponse
    
    /// Occurs when an invalid http method is used on an endpoint
    case methodNotAllowed
    
    /// Occurs when the body of the request isn't valid
    case invalidRequest
    
    /// Occurs when the server has an internal error
    case internalServerError
    
    /// Occurs when the API is disabled
    case unavailable
}

class ListenAPIClient {
    
    // MARK: - Properties
    
    private let session = URLSession(configuration: .default)
    private var history: [Exchange] = []
    
    /// Storage for caching the availability check for the query API
    ///
    /// `nil` means that we have not checked. On API failures `isAvailable` will remain `nil`.
    private (set) var isAvailable: Bool? = nil
    
    // MARK: - Init
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(significantTimeChangeNotificationFired), name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    // MARK: - Private Methods
    
    /// Reset the cached value for `isAvailable` on `UIApplication.significantTimeChangeNotification` firing.
    @objc private func significantTimeChangeNotificationFired() {
        isAvailable = nil
    }
    
    private func makeQueryAPIURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "query-ya3wxdzzgq-uc.a.run.app"
        return components.url
    }
    
    private func makeQueryAPIAvailableURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "query-api-enabled-ya3wxdzzgq-uc.a.run.app"
        return components.url
    }
    
    private func makeQueryAPIAvailableRequest() throws -> URLRequest {
        guard let url = makeQueryAPIAvailableURL() else {
            throw ListenAPIClientError.failedToMakeURLRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    private func makeRequest(for query: Query) throws -> URLRequest {
        guard let url = makeQueryAPIURL() else {
            throw ListenAPIClientError.failedToMakeURLRequest
        }
        
        var request = URLRequest(url: url)
        request.httpBody = try JSONEncoder().encode(query)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // MARK: - Public Methods
    
    func userResponded(to prompt: String, with response: String) {
        // If the user responds to the same prompt more than once, we only want the latest response.
        if history.last?.prompt == prompt {
            history.removeLast()
        }
        
        history.append(.init(prompt: prompt, response: response))
    }
    
    func isAvailable() async -> Bool {
        if let isAvailable {
            return isAvailable
        }
        
        do {
            let request = try makeQueryAPIAvailableRequest()
            let (_, response) = try await session.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            let available = httpResponse.map({ $0.statusCode == 200 }) ?? false
            
            self.isAvailable = available
            
            return available
        } catch {
            return false
        }
    }
    
    func query(_ prompt: String) async throws -> [String] {
        guard await isAvailable() else {
            throw ListenAPIClientError.unavailable
        }
        
        let query = Query(prompt: prompt, history: history)
        let request = try makeRequest(for: query)
        let (data, response) = try await session.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        
        switch httpResponse?.statusCode {
        case 200:
            isAvailable = true
            
            let reply = try JSONDecoder().decode(Reply.self, from: data)
            history = reply.history
            return reply.responses
            
        case 400:
            throw ListenAPIClientError.invalidRequest
            
        case 405:
            throw ListenAPIClientError.methodNotAllowed
            
        case 500:
            throw ListenAPIClientError.internalServerError
            
        case 503:
            isAvailable = false
            
            throw ListenAPIClientError.unavailable
            
        default:
            throw ListenAPIClientError.invalidResponse
        }
    }
    
}
