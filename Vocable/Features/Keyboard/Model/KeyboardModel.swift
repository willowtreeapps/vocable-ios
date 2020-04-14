//
//  KeyboardModel.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

struct KeyboardLocale {
    enum LanguageCode: String {
        case en
        case de
    }
    
    private struct OrientationKeyMapping {
        let landscape: String
        let compactPortrait: String
    }
    
    let languageCode: LanguageCode
    private let orientationKeyMapping: OrientationKeyMapping
    private init(preferredLanguageCode: String) {
        let code = Locale(identifier: preferredLanguageCode).languageCode ?? AppConfig.defaultLanguageCode
        languageCode = LanguageCode(rawValue: code) ?? .en
        orientationKeyMapping = KeyboardLocale.orientationKeyMapping(for: languageCode)
    }
    
    static var current: KeyboardLocale {
        return KeyboardLocale(preferredLanguageCode: AppConfig.activePreferredLanguageCode)
    }
    
    var landscape: String {
        return orientationKeyMapping.landscape
    }
    
    var compactPortrait: String {
        return orientationKeyMapping.compactPortrait
    }
    
    private static func orientationKeyMapping(for code: LanguageCode) -> OrientationKeyMapping {
        switch code {
        case .en:
            return .init(landscape: "QWERTYUIOPASDFGHJKL'ZXCVBNM,.?",
                         compactPortrait: "ABCDEFGHIJKLMNOPQRSTUVWXYZ',.?")
        case .de:
            return .init(landscape: "QWERTZUIOPÜASDFGHJKLÖÄYXCVBNMẞ'.?",
                         compactPortrait: "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜẞ/-',.?")
        }
    }
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
