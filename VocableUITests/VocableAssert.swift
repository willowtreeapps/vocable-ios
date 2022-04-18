//
//  VocableAssert.swift
//  VocableUITests
//
//  Custom assertions used within the VocableUITests module.
//
//  Created by Rudy Salas on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

class VocableAssert: XCTest {
    
    /// Use this function to confirm the expected state of the pagination label and its controls.
    ///
    /// By default this function expects the state of the left pagination arrow and the right pagination arrow to be isEnabled == true.
    func paginationEquals(_ expectedCurrentPageNumber: Int,
                          of expectedTotalPageCount: Int,
                          leftArrowEnabled: Bool = true,
                          rightArrowEnabled: Bool = true,
                          file: StaticString = #file,
                          line: UInt = #line)
    {
        
        XCTAssertEqual(BaseScreen().currentPageNumber, expectedCurrentPageNumber, file: file, line: line)
        XCTAssertEqual(BaseScreen().totalPageCount, expectedTotalPageCount, file: file, line: line)
        XCTAssertEqual(BaseScreen().paginationLeftButton.isEnabled, leftArrowEnabled, file: file, line: line)
        XCTAssertEqual(BaseScreen().paginationRightButton.isEnabled, rightArrowEnabled, file: file, line: line)
    }
    
}
