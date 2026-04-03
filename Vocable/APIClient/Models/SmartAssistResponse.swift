//
//  SmartAssistResponse.swift
//  Vocable
//
//  Created on 3/31/26.
//  Copyright © 2026 WillowTree. All rights reserved.
//

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26, *)
@Generable(description: "Suggested responses for an AAC user")
struct SmartAssistResponse {
    @Guide(description: "Short response phrases the user can select, preferring 1-3 words each",
           .minimumCount(1), .maximumCount(14))
    var responses: [String]
}
#endif
