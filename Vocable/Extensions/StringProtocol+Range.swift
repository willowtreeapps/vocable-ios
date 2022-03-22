//
//  StringProtocol+Range.swift
//  Vocable
//
//  Created by Robert Moyer on 3/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension StringProtocol {
    /// The range spanning the full length of the String
    var fullRange: Range<Index> {
        startIndex ..< endIndex
    }

    /// The range spanning the full length of the String, represented as an `NSRange`
    var fullNSRange: NSRange {
        nsRange(from: fullRange)
    }

    /// Converts a range of Indices to its `NSRange` representation.
    ///
    /// - Parameter rangeExpression: The range of string indices
    /// - Returns: The `NSRange` representation of the `rangeExpression`
    func nsRange<R: RangeExpression>(from rangeExpression: R) -> NSRange where R.Bound == Index {
        NSRange(rangeExpression, in: self)
    }
}
