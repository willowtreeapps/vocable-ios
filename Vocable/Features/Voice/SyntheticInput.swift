//
//  SyntheticInput.swift
//
//  Created by Chris Stroud on 6/19/20.
//  Copyright © 2020 WillowTree Apps. All rights reserved.
//

import Foundation

private let synthesized =
"""
do you want a coke or a pepsi


how many pickles



are you cold



apples or bananas


would you like a sandwich or pizza or salad
"""

enum SyntheticInput {

    static let values: [PhraseSequenceEntry]? = {
        guard ProcessInfo.processInfo.environment.keys.contains("UseDevelopmentInput") else {
            if let value = ProcessInfo.processInfo.environment["AutomationPhrase"] {
                return PhraseSequence.parseLiteral(value)
            }
            return nil
        }
        return PhraseSequence.parseLiteral(synthesized)
    }()
}
