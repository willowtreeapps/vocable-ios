//
//  PhraseSequence.swift
//
//  Created by Chris Stroud on 6/19/20.
//  Copyright © 2020 WillowTree Apps. All rights reserved.
//

import Foundation

public struct PhraseSequence {
    
    static func parseLiteral(_ input: String) -> [PhraseSequenceEntry] {
        var entries = [PhraseSequenceEntry]()
        var nextDelay: TimeInterval = 2 // Start with a 2s delay for initial phrase
        let splitSequence = input.split(separator: "\n", omittingEmptySubsequences: false)
        for entry in splitSequence {
            let trimmed = entry.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty, !entries.isEmpty {
                nextDelay += 1
            } else {
                entries.append(.init(trimmed, delay: nextDelay))
                nextDelay = 0
            }
        }
        return entries
    }
}

struct PhraseSequenceEntry: Codable {

    let phrase: String
    let delay: TimeInterval

    init(_ phrase: String, delay: TimeInterval = 0) {
        self.phrase = phrase
        self.delay = delay
    }
}
