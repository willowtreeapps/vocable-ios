//
//  ResultBuilders.swift
//  Vocable
//
//  Created by Chris Stroud on 4/25/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

@resultBuilder
enum ListBuilder<T> {
    static func buildBlock(_ components: T...) -> [T] {
        components
    }
}
