//
//  NavigationModel.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

enum HintText: CaseIterable {
    case preset
    case keyboard

    var localizedString: String {
        switch self {
        case .preset:
            return NSLocalizedString("main_screen.textfield_placeholder.default",
                                     comment: "Select something below to speak Hint Text")
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
    case close
    
    var image: UIImage? {
        switch self {
        case .save:
            return UIImage(systemName: "star")
        case .unsave:
            return UIImage(systemName: "star.fill")
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
        case .close:
            return UIImage(systemName: "xmark.circle")
            
        }
    }
}
