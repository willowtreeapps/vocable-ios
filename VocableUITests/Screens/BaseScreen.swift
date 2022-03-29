//
//  BaseScreen.swift
//  VocableUITests
//
//  Base screen Class used for common utility methods, to share among
//  all other screen Classes.
//
//  Created by Rudy Salas on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class BaseScreen {
    let paginationLabel = XCUIApplication().staticTexts["bottomPagination.pageNumber"]
    let alertMessageLabel = XCUIApplication().staticTexts["alert_message"]
    let emptyStateAddPhraseButton = XCUIApplication().buttons["empty_state_addPhrase_button"]
    
    /// From Pagination: the current page (X) being viewed from the "Page X of Y" pagination label.
    var currentPageNumber: Int {
        // Define a regex pattern with named matching group, 'current', for reference
        let pattern = #"(?<current>\d)+ .+ (\d)+"#
        
        let pageNumber = getNamedGroupInRegexPatternFromText(namedGroup: "current", regexPattern: pattern, text: paginationLabel.label)
        
        return Int(pageNumber)!
    }
    
    /// From Pagination: the total number of pages (Y) from the "Page X of Y" pagination label.
    var totalPageCount: Int {
        // Define a regex pattern with named matching group, 'total', for reference
        let pattern = #"(\d)+ .+ (?<total>\d)+"#
        
        let pageCount = getNamedGroupInRegexPatternFromText(namedGroup: "total", regexPattern: pattern, text: paginationLabel.label)
        
        return Int(pageCount)!
    }
    
    /**
     This method extracts a substring from text, that matches the named group within a defined regex pattern.
     
     For regex pattern #"Find (?\<groupdName\>\w)+ please"#, the \<groupName\> is matched from 'Find help please'
     to return 'help'
     
     Documentaion: https://nshipster.com/swift-regular-expressions/
    */
    private func getNamedGroupInRegexPatternFromText(namedGroup: String, regexPattern: String, text: String) -> String {
        var matchingText = ""
        let regex = try! NSRegularExpression(pattern: regexPattern)
        let range = NSRange(text.startIndex..<text.endIndex, in: text) // Used for the NSRegularExpression
        
        // Find a match to the regex pattern...
        if let match = regex.firstMatch(in: text, options: [], range: range) {
            // Within the match to the regex pattern, extract the matching group by its name
            let resultingMatch = match.range(withName: namedGroup)

            // Extract the Substring (as a String) of the found match from the range returned by regex.firstMatch
            matchingText = String(text[Range(resultingMatch, in: text)!])
        }
        
        return matchingText
    }
    
}
