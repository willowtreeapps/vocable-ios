//
//  CategoryOrderabilityTests.swift
//  VocableTests
//
//  Created by Chris Stroud on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest
@testable import Vocable

class CategoryOrderabilityTests: XCTestCase {

    func testDownwardOrderable() {

        let input = [1, 2, 3, 4]
        let model = CategoryOrderabilityModel(categories: input)

        let expectedResults = [false, true, true, true]
        zip(input.indexed().map(\.index), expectedResults).forEach { (index, expected) in
            let actual = model.canMoveToLowerIndex(from: index)
            XCTAssertEqual(expected, actual)
        }
    }

    func testUpwardOrderable() {

        let input = [1, 2, 3, 4]
        let model = CategoryOrderabilityModel(categories: input)

        let expectedResults = [true, true, true, false]
        zip(input.indexed().map(\.index), expectedResults).forEach { (index, expected) in
            let actual = model.canMoveToHigherIndex(from: index)
            XCTAssertEqual(expected, actual)
        }
    }

    func testPopulatedLowerIndexOutOfBounds() {

        let input = [1, 2, 3, 4]
        let model = CategoryOrderabilityModel(categories: input)

        XCTAssertFalse(model.canMoveToLowerIndex(from: -1))
    }

    func testEmptyLowerIndexOutOfBounds() {
        let model = CategoryOrderabilityModel(categories: [])
        XCTAssertFalse(model.canMoveToLowerIndex(from: 0))
    }

    func testPopulatedHigherIndexOutOfBounds() {

        let input = [1, 2, 3, 4]
        let model = CategoryOrderabilityModel(categories: input)

        XCTAssertFalse(model.canMoveToHigherIndex(from: 5))
    }

    func testEmptyHigherIndexOutOfBounds() {
        let model = CategoryOrderabilityModel(categories: [])
        XCTAssertFalse(model.canMoveToHigherIndex(from: 1))
    }

}
