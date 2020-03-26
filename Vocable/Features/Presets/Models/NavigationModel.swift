//
//  NavigationModel.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

enum HintText: String, CaseIterable {
    case preset = "Select something below to speak"
    case keyboard = ""

    var localizedString: String {
        switch self {
        case .preset:
            return NSLocalizedString("Select something below to speak", comment: "Select something below to speak Hint Text")
        default:
            return ""
        }
    }
}

enum TopBarButton: String {
    case save
    case unsave
    case toggleKeyboard
    case togglePreset
    case settings
    case back
    case confirmEdit
    
    var image: UIImage? {
        switch self {
        case .save:
            return UIImage(systemName: "suit.heart")
        case .unsave:
            return UIImage(systemName: "suit.heart.fill")
        case .toggleKeyboard:
            return UIImage(systemName: "keyboard")
        case .togglePreset:
            return UIImage(systemName: "text.bubble.fill")
        case .settings:
            return UIImage(systemName: "gear")
        case .back:
            return UIImage(systemName: "arrow.left")
        case .confirmEdit:
            return UIImage(systemName: "checkmark")
        }
    }
}
