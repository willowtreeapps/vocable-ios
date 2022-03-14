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
    // Define a regex pattern with named matching groups, 'current' and 'total', for reference
    let paginationRegexPattern = #"(?<current>\d)+ of (?<total>\d)+"#
    
    let paginationLabel = XCUIApplication().staticTexts["bottomPagination.pageNumber"]
    
    /// For Pagination: retrieve the current page (X) being viewed
    /// from the "Page X of Y" pagination label.
    func getCurrentPage() -> String {
        var currentPage = ""
        let fullLabel = paginationLabel.label
        
        let regex = try! NSRegularExpression(pattern: paginationRegexPattern)
        let range = NSRange(location: 0, length: fullLabel.count) // Used for the NSRegularExpression
        
        // Find a match to the regex pattern...
        if let match = regex.firstMatch(in: fullLabel, options: [], range: range) {
            // Within the match to the regex pattern, extract the matching group by its name
            let resultingMatch = match.range(withName: "current")

            // Extract the Substring (as a String) of the found match from the range returned by regex.firstMatch
            currentPage = String(fullLabel[Range(resultingMatch, in: fullLabel)!])
        }
        
        return currentPage
    }
    
    /// For Pagination: retrieve the total number of pages (Y) from the
    ///  "Page X of Y" pagination label.
    func getTotalNumOfPages() -> String {
        var totalPages = ""
        let fullLabel = paginationLabel.label
        
        let regex = try! NSRegularExpression(pattern: paginationRegexPattern)
        let range = NSRange(location: 0, length: fullLabel.count) // Used for the NSRegularExpression
        
        // Find a match to the regex pattern...
        if let match = regex.firstMatch(in: fullLabel, options: [], range: range) {
            // Within the match to the regex pattern, extract the matching group by its name
            let resultingMatch = match.range(withName: "total")

            // Extract the Substring (as a String) of the found match from the range returned by regex.firstMatch
            totalPages = String(fullLabel[Range(resultingMatch, in: fullLabel)!])
        }
        
        return totalPages
    }
    
}
