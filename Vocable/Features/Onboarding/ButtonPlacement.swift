//
//  ButtonPlacement.swift
//  Vocable
//
//  Created by Joe Romero on 12/2/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

enum ButtonPlacement: CaseIterable {
    case leadingTop
    case leadingBottom
    case trailingTop
    case trailingBottom

    var clockwise: Bool {
        switch self {
        case .leadingTop, .trailingTop:
            return true
        case .leadingBottom, .trailingBottom:
            return false
        }
    }
}
