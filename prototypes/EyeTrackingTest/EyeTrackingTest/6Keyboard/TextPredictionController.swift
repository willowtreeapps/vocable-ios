//
//  TextPredictionController.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol TextPredictionControllerDelegate: class {
    func textPredictionController(_ controller: TextPredictionController, didUpdatePrediction value: String, at index: Int)
    func textPredictionController(_ controller: TextPredictionController, didUpdateSentence sentence: Sentence)
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
    
    var sentence = Sentence()
    
    func updateState(newText: String) {
        print("Updated String: \(newText)")
        self.sentence.sentence = newText
        self.updateState()
    }
    
    private func updateState() {
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
        self.delegate?.textPredictionController(self, didUpdateSentence: self.sentence)
    }
    
    private func completions() -> [String] {
        self.state = self.sentence.sentence.hasExtraWhitespace ? .matchByPhrase : .matchByWord
        return self.matches()
    }
    
    private func matches() -> [String] {
        return self.state == .matchByPhrase ? matchesByPhrase() : matchesByWord()
    }
    
    private func matchesByPhrase() -> [String] {
        let splitSentence = self.sentence.splitSentence
        var lastPhrase = self.sentence.sentence
        if splitSentence.count > 2 {
            let lastElement = splitSentence[splitSentence.count - 1]
            let secondToLastElement = splitSentence[splitSentence.count - 2]
            lastPhrase = "\(secondToLastElement) \(lastElement)"
        }
        let augmentedString = lastPhrase + " *"
        let checker = UITextChecker()
        let range = NSRange(location: (lastPhrase as NSString).length, length: -1)
        var joinedArray: [String] = []
        let guesses = checker.guesses(forWordRange: range, in: augmentedString, language: "en_US") ?? []
        let completions = checker.completions(forPartialWordRange: range, in: augmentedString, language: "en_US") ?? []
        joinedArray.append(contentsOf: completions)
        joinedArray.append(contentsOf: guesses)
        return joinedArray
    }
    
    private func matchesByWord() -> [String] {
        let fullSentence = self.sentence.sentence
        let lastWord = self.sentence.lastWord() ?? ""
        let checker = UITextChecker()
        let range = NSRange(location: (fullSentence as NSString).length - (lastWord as NSString).length, length: (lastWord as NSString).length)
        var joinedArray: [String] = []
        let guesses = checker.guesses(forWordRange: range, in: fullSentence, language: "en_US") ?? []
        let completions = checker.completions(forPartialWordRange: range, in: fullSentence, language: "en_US") ?? []
        joinedArray.append(contentsOf: completions)
        joinedArray.append(contentsOf: guesses)
        return joinedArray
    }
    
    func updateSentence(withPredictionAt index: Int) {
        let lastWord = self.prediction(index: index)
        if self.state == .matchByPhrase {
            self.sentence.add(word: lastWord)
        } else {
            self.sentence.replaceLastWord(with: lastWord)
            
        }
        self.sentence.sentence.append(" ")
        self.updateState()
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
