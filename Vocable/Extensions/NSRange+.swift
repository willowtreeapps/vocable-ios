//
//  StringProtocol+Range.swift
//  Vocable
//
//  Created by Robert Moyer on 3/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension NSRange {
    init<S: StringProtocol>(of s: S) {
        self.init(s.rangeOfIndices, in: s)
    }

    static func entireRange<S: StringProtocol>(of s: S) -> NSRange {
        NSRange(s.rangeOfIndices, in: s)
    }
}
