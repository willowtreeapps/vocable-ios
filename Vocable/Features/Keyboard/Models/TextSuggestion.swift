//
//  PredictiveText.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct TextSuggestion: Hashable {
    let text: String
    let id = UUID()
}
