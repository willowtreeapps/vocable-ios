//
//  ButtonState.swift
//  Vocable
//
//  Created by Robert Moyer on 4/7/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

/// Constants describing the state of a button
struct ButtonState: OptionSet {
    let rawValue: UInt

    /// The normal or default state of a button, neither selected nor highlighted
    static let normal       = Self([])

    /// Highlighted state of a button
    ///
    /// A button becomes highlighted when a touch or gaze event
    /// enters the button's bounds, and it loses that highlight
    /// when there is a touch-up event or when the touch/gaze event
    /// exits the button's bounds.
    static let highlighted  = Self(rawValue: 1 << 0)

    /// Selected state of a button
    static let selected     = Self(rawValue: 1 << 1)
}
