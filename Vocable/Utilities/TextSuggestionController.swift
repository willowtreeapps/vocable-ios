//
//  TextSuggestionController.swift
//  Vocable AAC
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//
import UIKit

class TextSuggestionController {
    
    private let checker = UITextChecker()
    
    func suggestions(for expression: TextExpression) -> [String] {
        let fullExpression = expression.value
        let lastWord = expression.lastWord() ?? ""
        let range = NSRange(location: (fullExpression as NSString).length - (lastWord as NSString).length, length: (lastWord as NSString).length)
        var joinedArray: [String] = []
        let guesses = checker.guesses(forWordRange: range, in: fullExpression, language: Locale.current.identifier) ?? []
        let completions = checker.completions(forPartialWordRange: range, in: fullExpression, language: AppConfig.preferredLanguageIdentifier) ?? []
        joinedArray.append(contentsOf: completions)
        joinedArray.append(contentsOf: guesses)
        return joinedArray
    }

}
