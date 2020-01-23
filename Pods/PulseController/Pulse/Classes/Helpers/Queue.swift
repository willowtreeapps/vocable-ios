//
//  Queue.swift
//  Pulse
//
//  Created by Dawid Cieslak on 16/04/2018.
//  Copyright © 2018 Dawid Cieslak. All rights reserved.
//
import UIKit

/// Provides FILO queue in fixed size
///
/// @discussion: This is "ring" type of queue - older values will be overwritten with new ones
struct Queue<T> {
    
    /// Current index of cell to store new value
    private var writeHeadIndex: Int = 0
    
    /// Stores all elements
    private var array: [T]
    
    /// Init with queue configuration
    ///
    /// - Parameters:
    ///   - count: Maximum count of elements
    ///   - initialValue: Initial value for all elements
    init(count: Int, initialValue: T) {
        array = [T](repeating: initialValue, count: count)
    }
    
    /// Adds given value to queue
    ///
    /// - Parameter value: Value to be added
    mutating func append(value: T) {
        array[writeHeadIndex] = value
        
        // Move pointer
        writeHeadIndex = (writeHeadIndex + 1) % array.count
    }
    
    
    /// Retrives of all elements in queue and returns in revered order (oldest element is firest)
    ///
    /// - Returns: Array of all elements in reversed order
    func allValuesReversed() -> [T] {
        var allValues:[T] = [T]()
        
        for i in 1...array.count {
            let readIndex = (writeHeadIndex - i + array.count) % array.count
            let currentValue = array[readIndex]
            allValues.append(currentValue)
        }
        
        return allValues
    }
    
}
