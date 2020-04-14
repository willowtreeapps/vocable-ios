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
    static var qwerty: String {
        if AppConfig.activePreferredLanguageCode.contains("de-") {
          return deUSQwerty
        }
        return enUSQwerty
    }
    
    static var alphabetical: String {
        if AppConfig.activePreferredLanguageCode.contains("de-") {
          return deUSAlphabetical
        }
        return enUSAlphabetical
    }
    
    static var enUSQwerty = "QWERTYUIOPASDFGHJKL'ZXCVBNM,.?"
    static var enUSAlphabetical = "ABCDEFGHIJKLMNOPQRSTUVWXYZ',.?"
    
    static var deUSQwerty = "QWERTZUIOPÜASDFGHJKLÖÄYXCVBNMẞ'.?"
    static var deUSAlphabetical = "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜẞ/-',.?"
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
