//
//  TextExpression.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/16/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//
import Foundation

class TextExpression {
    private(set) var value: String = ""
    
    private let textSuggestionController = TextSuggestionController()

    var wordCount: Int {
        return value.split(separator: " ").count
    }

    var splitExpression: [String] {
        let trimmedExpression = self.value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedExpression.split(separator: " ").map { String($0) }
    }

    func add(word: String) {
        let trimmedExpression = self.value.trimmingCharacters(in: .whitespacesAndNewlines)
        var newSplitExpression = trimmedExpression.split(separator: " ").map { String($0) }
        newSplitExpression.append(word)
        self.value = newSplitExpression.joined(separator: " ")
    }

    func replaceWord(at index: Int, with newWord: String) {
        var newSplitExpression = self.splitExpression
        if newSplitExpression.count > index && index >= 0 {
            newSplitExpression[index] = newWord
        }
        self.value = newSplitExpression.joined(separator: " ")
    }

    func replaceLastWord(with newWord: String) {
        self.replaceWord(at: self.splitExpression.count - 1, with: newWord)
    }

    func word(at index: Int) -> String? {
        return self.splitExpression[safe: index]
    }

    func lastWord() -> String? {
        return word(at: self.splitExpression.count - 1)
    }

    func backspace() {
        if !self.value.isEmpty {
            _ = self.value.removeLast()
        }
    }

    func append(text: String) {
        value.append(text)
    }
    
    func replace(text: String) {
        value = text
    }

    func clear() {
        value = ""
    }

    func space() {
        self.value.append(" ")
    }
    
    func suggestions() -> [String] {
        return textSuggestionController.suggestions(for: self)
    }
}
