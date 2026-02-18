//
//  TextTransaction.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

struct TextTransaction: CustomDebugStringConvertible {

    var text: String
    /// Insertion point: 0...text.count. Defaults to text.count (end) for append-at-end behavior.
    var cursorIndex: Int {
        get { _cursorIndex }
        set { _cursorIndex = min(max(0, newValue), text.count) }
    }
    private var _cursorIndex: Int

    let attributedText: NSMutableAttributedString
    private let lastChararacterRange: NSRange
    private let lastTokenRange: NSRange
    private let intent: Intent
    let isHint: Bool

    var debugDescription: String {
        return "TextDescription(text: \(text), cursorIndex: \(cursorIndex), lastCharacterRange: \(String(describing: lastChararacterRange)), lastTokenRange: \(lastTokenRange), changeType: \(intent), isHint: \(isHint))"
    }

    init(text: String, intent: Intent = .none, isHint: Bool = false, speakingRange: NSRange? = nil, cursorIndex: Int? = nil) {
        if text.count == 1 {
            self.text = text.uppercased()
        } else {
            self.text = text
        }
        self.isHint = isHint
        let effectiveCursor = min(max(0, cursorIndex ?? self.text.count), self.text.count)
        _cursorIndex = effectiveCursor

        let (charRange, tokenRange) = Self.computeRangesForCursor(in: self.text, cursorIndex: effectiveCursor)
        lastChararacterRange = charRange
        lastTokenRange = tokenRange

        let standardAttributes = [NSAttributedString.Key.foregroundColor: UIColor.defaultTextColor as Any]
        let highlightedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.highlightedTextColor as Any]
        attributedText = NSMutableAttributedString(string: self.text, attributes: standardAttributes)

        switch intent {
        case .fullWord:
            attributedText.addAttributes(highlightedAttributes, range: lastTokenRange)
        case .lastCharacter:
            attributedText.addAttributes(highlightedAttributes, range: lastChararacterRange)
        case .none:
            break
        }

        if let speakingRange {
            attributedText.addAttribute(.foregroundColor, value: UIColor.cellBorderHighlightColor, range: speakingRange)
        }
        attributedText.addAttribute(
            .font,
            value: UIFont.textEditor(),
            range: NSRange(location: 0, length: attributedText.length)
        )
        self.intent = intent
    }

    /// Character range immediately before cursor (one character) and token range ending before/at cursor.
    private static func computeRangesForCursor(in text: String, cursorIndex: Int) -> (NSRange, NSRange) {
        let n = text.count
        guard cursorIndex > 0, n > 0 else {
            return (NSRange(location: 0, length: 0), NSRange(location: 0, length: 0))
        }
        let charRange = NSRange(location: cursorIndex - 1, length: 1)
        let tokenRange: NSRange
        if cursorIndex >= n {
            let lastTokenExpr = "[^\\s]*\\s*$"
            tokenRange = computeRange(with: text, using: lastTokenExpr)
        } else {
            let start = tokenStartIndex(before: cursorIndex, in: text)
            tokenRange = NSRange(location: start, length: cursorIndex - start)
        }
        return (charRange, tokenRange)
    }

    /// Start index (character offset) of the word that ends just before `cursorIndex`.
    private static func tokenStartIndex(before cursorIndex: Int, in text: String) -> Int {
        guard cursorIndex > 0 else { return 0 }
        let endIndex = text.index(text.startIndex, offsetBy: cursorIndex, limitedBy: text.endIndex) ?? text.endIndex
        let segment = text[..<endIndex]
        guard let lastSpace = segment.lastIndex(where: { $0.isWhitespace }) else {
            return 0
        }
        return text.distance(from: text.startIndex, to: text.index(after: lastSpace))
    }

    /// Start and end (character offsets) of the word that contains the cursor, or the word before cursor if cursor is at a space.
    private static func tokenRangeContainingCursor(in text: String, cursorIndex: Int) -> NSRange {
        let n = text.count
        guard n > 0 else { return NSRange(location: 0, length: 0) }
        var start = cursorIndex
        var end = cursorIndex
        let chars = Array(text)
        while start > 0 && !chars[start - 1].isWhitespace {
            start -= 1
        }
        while end < n && !chars[end].isWhitespace {
            end += 1
        }
        return NSRange(location: start, length: end - start)
    }

    private static func computeRange(with text: String, using expr: String) -> NSRange {
        let regex = try! NSRegularExpression(pattern: expr, options: .anchorsMatchLines)
        if let result = regex.firstMatch(in: text, options: .init(), range: NSRange(location: 0, length: text.count)) {
            return result.range
        } else {
            return NSRange(location: 0, length: 0)
        }
    }

    func deletingLastToken() -> TextTransaction {
        guard cursorIndex > 0 else {
            return TextTransaction(text: text, intent: .lastCharacter, isHint: isHint, cursorIndex: 0)
        }
        let newText: String
        let deletedLength: Int
        switch intent {
        case .fullWord:
            deletedLength = lastTokenRange.length
            newText = NSString(string: text).replacingCharacters(in: lastTokenRange, with: "")
        case .lastCharacter:
            deletedLength = lastChararacterRange.length
            newText = NSString(string: text).replacingCharacters(in: lastChararacterRange, with: "")
        case .none:
            return TextTransaction(text: text, intent: .lastCharacter, isHint: isHint, cursorIndex: cursorIndex)
        }
        let newCursor = max(0, cursorIndex - deletedLength)
        return TextTransaction(text: newText, intent: .lastCharacter, isHint: isHint, cursorIndex: newCursor)
    }

    mutating func deleteLastToken() {
        self = self.deletingLastToken()
    }

    mutating func clear() {
        self = .init(text: "", intent: .none, cursorIndex: 0)
    }

    func appendingCharacter(with character: String) -> TextTransaction {
        if isHint {
            return TextTransaction(text: character, intent: .lastCharacter, cursorIndex: 1)
        }
        let (newText, newCursor) = handleGrammarAndInsert(character, at: cursorIndex)
        return TextTransaction(text: newText, intent: .lastCharacter, cursorIndex: newCursor)
    }

    mutating func append(_ str: String) {
        self = self.appendingCharacter(with: str)
    }

    func insertingSuggestion(with suggestion: String) -> TextTransaction {
        let range = Self.tokenRangeContainingCursor(in: text, cursorIndex: cursorIndex)
        let newText = NSString(string: text).replacingCharacters(in: range, with: suggestion)
        let newCursor = range.location + suggestion.count
        return TextTransaction(text: newText, intent: .fullWord, cursorIndex: newCursor)
    }

    mutating func insert(_ suggestion: String) {
        self = self.insertingSuggestion(with: suggestion)
    }

    /// Inserts character at cursorIndex and applies grammar; returns (newText, newCursorIndex).
    private func handleGrammarAndInsert(_ character: String, at index: Int) -> (String, Int) {
        var prefix = String(text.prefix(index))
        var suffix = String(text.dropFirst(index))
        var char = character.lowercased()
        let punctuation = ["'", ",", ".", "?"]

        let trimmedPrefix = prefix.trimmingCharacters(in: .whitespaces)
        if let lastCharacter = trimmedPrefix.last {
            if punctuation.contains(String(lastCharacter)) && lastCharacter != "'" {
                prefix = trimmedPrefix + " "
            }
            if lastCharacter == "." || lastCharacter == "?" {
                char = char.uppercased()
            }
        }
        if punctuation.contains(char) && prefix.last == " " {
            prefix = prefix.trimmingCharacters(in: .whitespaces)
        }

        let insertPosition = prefix.count
        let newText = prefix + char + suffix
        let newCursor = insertPosition + char.count
        return (newText, newCursor)
    }

    func withSpeakingRange(_ range: NSRange?) -> TextTransaction {
        .init(text: self.text, intent: self.intent, isHint: self.isHint, speakingRange: range, cursorIndex: self.cursorIndex)
    }

    mutating func setSpeakingRange(_ range: NSRange?) {
        self = self.withSpeakingRange(range)
    }

    func movingCursorLeft() -> TextTransaction {
        let newCursor = max(0, cursorIndex - 1)
        return TextTransaction(text: text, intent: intent, isHint: isHint, cursorIndex: newCursor)
    }

    mutating func moveCursorLeft() {
        self = self.movingCursorLeft()
    }

    func movingCursorRight() -> TextTransaction {
        let newCursor = min(text.count, cursorIndex + 1)
        return TextTransaction(text: text, intent: intent, isHint: isHint, cursorIndex: newCursor)
    }

    mutating func moveCursorRight() {
        self = self.movingCursorRight()
    }

    // To keep track of when to delete the last word or the full word (after selecting a text suggestion) when pressing backspace
    // on the keyboard.
    enum Intent {
        case lastCharacter
        case fullWord
        case none
    }
}
