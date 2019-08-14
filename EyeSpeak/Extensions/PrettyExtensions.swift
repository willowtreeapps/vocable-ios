//
//  PrettyExtensions.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 5/1/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension String {
    static let empty = ""
    static let period = "."
    static let comma = ","
    static let backspaceWithUnicode = "\u{2190} bksp"
}

extension UIEdgeInsets {
    init(value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
}
