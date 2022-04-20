//
//  VocableTestAsserts.swift
//  VocableUITests
//
//  Custom assertions used within the VocableUITests module.
//
//  Created by Rudy Salas on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

struct PaginationArrows: OptionSet {

    let rawValue: Int8

    static let left = PaginationArrows(rawValue: 1)
    static let right = PaginationArrows(rawValue: 1 << 1)

    static let both: PaginationArrows = [.left, .right]
    static let none: PaginationArrows = []
}
    
/// This assertion function confirms the expected state of the pagination label and its controls.
///
/// By default this function expects the state of the left pagination arrow and the right pagination arrow to be isEnabled == true.
func VTAssertPaginationEquals(_ expectedCurrentPageNumber: Int,
                              of expectedTotalPageCount: Int,
                              enabledArrows: PaginationArrows = .both,
                              file: StaticString = #file,
                              line: UInt = #line)
{
    XCTAssertEqual(BaseScreen.currentPageNumber, expectedCurrentPageNumber, file: file, line: line)
    XCTAssertEqual(BaseScreen.totalPageCount, expectedTotalPageCount, file: file, line: line)
    XCTAssertEqual(BaseScreen.paginationLeftButton.isEnabled, enabledArrows.contains(.left), file: file, line: line)
    XCTAssertEqual(BaseScreen.paginationRightButton.isEnabled, enabledArrows.contains(.right), file: file, line: line)
}
