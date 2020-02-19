//
//  TextTransaction.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

struct TextTransaction: CustomDebugStringConvertible {
    
    let text: String
    let attributedText: NSMutableAttributedString
    private let lastChararacterRange: NSRange
    private let lastTokenRange: NSRange
    private let intent: Intent
    let isHint: Bool
    
    var debugDescription: String {
        return "TextDescription(text: \(text), lastCharacterRange: \(String(describing: lastChararacterRange)), lastTokenRange: \(lastTokenRange), changeType: \(intent), isHint: \(isHint))"
    }
    
    init(text: String, intent: Intent = .none, isHint: Bool = false) {
        if text.count == 1 {
            self.text = text.uppercased()
        } else {
            self.text = text
        }
        self.isHint = isHint
        
        let lastCharacterExpr = ".$"
        lastChararacterRange = TextTransaction.computeRange(with: self.text, using: lastCharacterExpr)
        
        let lastTokenExpr = "[^\\s]*\\s*$"
        lastTokenRange = TextTransaction.computeRange(with: self.text, using: lastTokenExpr)
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "TextHighlight")!]
        attributedText = NSMutableAttributedString(string: self.text)
        
        switch intent {
        case .fullWord:
            attributedText.addAttributes(attributes, range: lastTokenRange)
        case .lastCharacter:
            attributedText.addAttributes(attributes, range: lastChararacterRange)
        case .none:
            break
        }
        
        self.intent = intent
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
        let newText: String
        switch intent {
        case .fullWord:
            newText = NSString(string: text).replacingCharacters(in: lastTokenRange, with: "")
        case .lastCharacter:
            newText = NSString(string: text).replacingCharacters(in: lastChararacterRange, with: "")
        case .none:
            return TextTransaction(text: text, intent: .lastCharacter)
        }
        return TextTransaction(text: newText, intent: .lastCharacter)
    }
    
    func appendingCharacter(with character: String) -> TextTransaction {
        if isHint {
            return TextTransaction(text: character, intent: .lastCharacter)
        }
        
        return TextTransaction(text: text + character.lowercased(), intent: .lastCharacter)
    }
    
    func insertingSuggestion(with suggestion: String) -> TextTransaction {
        let newText: String
        newText = NSString(string: text + " ").replacingCharacters(in: lastTokenRange, with: suggestion)
        return TextTransaction(text: newText, intent: .fullWord)
    }
    
    // To keep track of when to delete the last word or the full word (after selecting a text suggestion) when pressing backspace
    // on the keyboard.
    enum Intent {
        case lastCharacter
        case fullWord
        case none
    }
    
}
