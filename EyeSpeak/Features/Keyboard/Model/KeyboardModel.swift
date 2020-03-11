//
//  KeyboardModel.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardKeys {
    static var qwerty = "QWERTYUIOPASDFGHJKL'ZXCVBNM,.?"
    static var alphabetical = "ABCDEFGHIJKLMNOPQRSTUVWXYZ',.?"
}

enum KeyboardFunctionButton {
    case clear
    case backspace
    case space
    case speak
    
    var image: UIImage {
        switch self {
        case .clear:
            return UIImage(systemName: "trash")!
        case .backspace:
            return UIImage(systemName: "delete.left")!
        case .space:
            return UIImage(named: "underscore")!
        case .speak:
            return UIImage(named: "Speak")!
        }
    }
}
