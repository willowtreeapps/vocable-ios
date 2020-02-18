//
//  CircularRange.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

/// A range of a certain size that will clamp between `0..<upperBound`.
///
/// If a caller attempts to push the range past its bounds,
/// it will wrap around and return a range of the same size starting at the lower bound or ending at the upper bound.
@propertyWrapper
struct CircularRange {
    private let size: Int
    private let upperBound: Int
    
    private var clampedRange: Range<Int>
 
    init(size: Int, upperBound: Int) {
        self.size = size
        self.upperBound = upperBound
        self.clampedRange = 0..<upperBound
    }
    
    var wrappedValue: Range<Int> {
        get {
            clampedRange.clamped(to: clampedRange.startIndex..<clampedRange.startIndex + size)
        } set {
            if newValue.startIndex > upperBound - 1 {
                clampedRange = 0..<size
            } else if newValue.startIndex < 0 {
                let startIndex = upperBound - (upperBound % size)
                let endIndex = startIndex + size
                clampedRange = startIndex..<endIndex
            } else {
                clampedRange = newValue
            }
        }
    }
}
