//
//  FixedQueue.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/25/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

class FixedQueue<T> {
    let maxSize: Int
    
    private(set) var elements: [T] = []
    
    private var size: Int {
        return self.elements.count
    }
    
    init(maxSize: Int) {
        self.maxSize = maxSize
    }
    
    func add(element: T?) {
        if let element = element {
            self.elements.append(element)
            while self.size > self.maxSize {
                self.elements.removeFirst()
            }
        }
    }
}
