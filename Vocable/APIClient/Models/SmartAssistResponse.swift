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
    @Guide(description: "Short response phrases the user can select, under 10 words each",
           .minimumCount(2), .maximumCount(5))
    var responses: [String]
}
#endif
