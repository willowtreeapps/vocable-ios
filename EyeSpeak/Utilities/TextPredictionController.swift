//
//  TextPredictionController.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//
import UIKit

class TextPredictionController {
    
    private let checker = UITextChecker()

    func predictions(for expression: TextExpression) -> [String] {
        return expression.value.hasExtraWhitespace ? matchesByPhrase(expression: expression) : matchesByWord(expression: expression)
    }

    private func matchesByPhrase(expression: TextExpression) -> [String] {
        return phraseCompletions(expression: expression, neededCompletions: 5)
    }

    private func phraseCompletions(expression: TextExpression, neededCompletions: Int) -> [String] {
        var splitExpression = expression.splitExpression
        var completions: [String] = []
        while !splitExpression.isEmpty && completions.count < neededCompletions {
            let phrase = splitExpression.joined(separator: " ")
            let augmentedString = phrase + " *"
            let range = NSRange(location: (phrase as NSString).length, length: -1)
            let phraseCompletions = checker.completions(forPartialWordRange: range, in: augmentedString, language: "en_US") ?? []
            completions.append(contentsOf: phraseCompletions)
            splitExpression.removeFirst()
        }
        return completions
    }

    private func matchesByWord(expression: TextExpression) -> [String] {
        let fullExpression = expression.value
        let lastWord = expression.lastWord() ?? ""
        let range = NSRange(location: (fullExpression as NSString).length - (lastWord as NSString).length, length: (lastWord as NSString).length)
        var joinedArray: [String] = []
        let guesses = checker.guesses(forWordRange: range, in: fullExpression, language: "en_US") ?? []
        let completions = checker.completions(forPartialWordRange: range, in: fullExpression, language: "en_US") ?? []
        joinedArray.append(contentsOf: completions)
        joinedArray.append(contentsOf: guesses)
        return joinedArray
    }
}

extension String {
    var hasExtraWhitespace: Bool {
        return self.count != self.trimmingCharacters(in: .whitespacesAndNewlines).count
    }
}
