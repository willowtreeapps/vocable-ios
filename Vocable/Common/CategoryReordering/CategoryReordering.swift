//
//  CategoryReordering.swift
//  Vocable
//
//  Created by Chris Stroud on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

struct CategoryOrderabilityModel<T: BidirectionalCollection> {

    private let upwardOrderableIndices: Range<T.Index>
    private let downwardOrderableIndices: Range<T.Index>

    init(categories: T) {
        let lowestDownwardOrderableIndex = categories.index(categories.startIndex, offsetBy: 1, limitedBy: categories.endIndex) ?? categories.endIndex
        downwardOrderableIndices = lowestDownwardOrderableIndex ..< categories.endIndex

        let highestUpwardOrderableIndex = categories.index(categories.endIndex, offsetBy: -1, limitedBy: categories.startIndex) ?? categories.startIndex
        upwardOrderableIndices = categories.startIndex ..< highestUpwardOrderableIndex
    }

    func canMoveToHigherIndex(from index: T.Index) -> Bool {
        upwardOrderableIndices.contains(index)
    }

    func canMoveToLowerIndex(from index: T.Index) -> Bool {
        downwardOrderableIndices.contains(index)
    }
}
