//
//  Sentence.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/16/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation


class Sentence {
    var sentence: String = ""
    
    var wordCount: Int {
        return sentence.split(separator: " ").count
    }
    
    var splitSentence: [String] {
        let trimmedSentence = self.sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedSentence.split(separator: " ").map { String($0) }
    }
    
    func add(word: String) {
        let trimmedSentence = self.sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        var newSplitSentence = trimmedSentence.split(separator: " ").map { String($0) }
        newSplitSentence.append(word)
        self.sentence = newSplitSentence.joined(separator: " ")
    }
    
    func replaceWord(at index: Int, with newWord: String) {
        var newSplitSentence = self.splitSentence
        if newSplitSentence.count > index && index >= 0 {
            newSplitSentence[index] = newWord
        }
        self.sentence = newSplitSentence.joined(separator: " ")
    }
    
    func replaceLastWord(with newWord: String) {
        self.replaceWord(at: self.splitSentence.count - 1, with: newWord)
    }
    
    func word(at index: Int) -> String? {
        if self.splitSentence.count > index && index >= 0 {
            return self.splitSentence[index]
        } else {
            return nil
        }
    }
    
    func lastWord() -> String? {
        return word(at: self.splitSentence.count - 1)
    }
}
