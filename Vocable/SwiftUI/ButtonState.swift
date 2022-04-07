//
//  ButtonState.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

struct ButtonState: OptionSet {
    let rawValue: UInt

    static let normal       = Self([])
    static let highlighted  = Self(rawValue: 1 << 0)
    static let selected     = Self(rawValue: 1 << 1)
}
