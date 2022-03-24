//
//  BidirectionalCollection+.swift
//  Vocable
//
//  Created by Robert Moyer on 3/23/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

extension BidirectionalCollection {
    /// The range spanning all valid indices of the collection
    var rangeOfIndices: Range<Index> {
        startIndex ..< endIndex
    }
}
