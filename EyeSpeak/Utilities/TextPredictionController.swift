//
//  TextPredictionController.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//
import UIKit

protocol TextPredictionControllerDelegate: class {
    func textPredictionController(_ controller: TextPredictionController, didUpdatePrediction value: String, at index: Int)
}

enum TextPredictionControllerState {
    case idle
    case matchByPhrase
    case matchByWord
}

class TextPredictionController {
    var prediction1: String = ""
    var prediction2: String = ""
    var prediction3: String = ""
    var prediction4: String = ""
    var prediction5: String = ""
    var prediction6: String = ""

    weak var delegate: TextPredictionControllerDelegate?
    var state: TextPredictionControllerState = .idle
    private var expression = TextExpression()
    private let checker = UITextChecker()

    func updateState(withTextExpression expression: TextExpression) {
        self.expression = expression
        let completions = self.completions()
        self.prediction1 = ""
        self.prediction2 = ""
        self.prediction3 = ""
        self.prediction4 = ""
        self.prediction5 = ""
        self.prediction6 = ""
        if let prediction1 = completions[safe: 0] {
            self.prediction1 = prediction1
        }
        if let prediction2 = completions[safe: 1] {
            self.prediction2 = prediction2
        }
        if let prediction3 = completions[safe: 2] {
            self.prediction3 = prediction3
        }
        if let prediction4 = completions[safe: 3] {
            self.prediction4 = prediction4
        }
        if let prediction5 = completions[safe: 4] {
            self.prediction5 = prediction5
        }
        if let prediction6 = completions[safe: 5] {
            self.prediction6 = prediction6
        }
        self.delegate?.textPredictionController(self, didUpdatePrediction: self.prediction1, at: 0)
        self.delegate?.textPredictionController(self, didUpdatePrediction: self.prediction2, at: 1)
        self.delegate?.textPredictionController(self, didUpdatePrediction: self.prediction3, at: 2)
        self.delegate?.textPredictionController(self, didUpdatePrediction: self.prediction4, at: 3)
        self.delegate?.textPredictionController(self, didUpdatePrediction: self.prediction5, at: 4)
        self.delegate?.textPredictionController(self, didUpdatePrediction: self.prediction6, at: 5)
    }

    private func completions() -> [String] {
        self.state = self.expression.value.hasExtraWhitespace ? .matchByPhrase : .matchByWord
        return self.matches()
    }

    private func matches() -> [String] {
        return self.state == .matchByPhrase ? matchesByPhrase() : matchesByWord()
    }

    private func matchesByPhrase() -> [String] {
        return phraseCompletions(neededCompletions: 6)
    }

    private func phraseCompletions(neededCompletions: Int) -> [String] {
        var splitExpression = self.expression.splitExpression
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

    private func matchesByWord() -> [String] {
        let fullExpression = self.expression.value
        let lastWord = self.expression.lastWord() ?? ""
        let range = NSRange(location: (fullExpression as NSString).length - (lastWord as NSString).length, length: (lastWord as NSString).length)
        var joinedArray: [String] = []
        let guesses = checker.guesses(forWordRange: range, in: fullExpression, language: "en_US") ?? []
        let completions = checker.completions(forPartialWordRange: range, in: fullExpression, language: "en_US") ?? []
        joinedArray.append(contentsOf: completions)
        joinedArray.append(contentsOf: guesses)
        return joinedArray
    }

    func updateExpression(withPredictionAt index: Int) {
        let lastWord = self.prediction(index: index)
        guard !lastWord.isEmpty else { return }
        if self.state == .matchByPhrase {
            self.expression.add(word: lastWord)
        } else {
            self.expression.replaceLastWord(with: lastWord)
        }
        self.expression.space()
    }

    private func prediction(index: Int) -> String {
        switch index {
        case 0:
            return self.prediction1
        case 1:
            return self.prediction2
        case 2:
            return self.prediction3
        case 3:
            return self.prediction4
        case 4:
            return self.prediction5
        case 5:
            return self.prediction6
        default:
            return ""
        }
    }
}

extension String {
    var hasExtraWhitespace: Bool {
        return self.count != self.trimmingCharacters(in: .whitespacesAndNewlines).count
    }
}
