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
