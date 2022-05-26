//
//  UIAccessibilityIdentification+AccessibilityID.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension UIAccessibilityIdentification {
    var accessibilityID: AccessibilityID {
        get {
            AccessibilityID(stringLiteral: self.accessibilityIdentifier ?? "")
        }
        set {
            self.accessibilityIdentifier = newValue.id
        }
    }
}
