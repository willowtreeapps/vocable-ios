//
//  UIAccessibilityIdentification+AXElement.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIAccessibilityIdentification {

    // Experimental
    var accessibilityElement: AXElement {
        get {
            AXElement(stringLiteral: self.accessibilityIdentifier ?? "")
        }
        set {
            self.accessibilityIdentifier = newValue.id
        }
    }

    var accessibilityID: AccessibilityID {
        get {
            AccessibilityID(stringLiteral: self.accessibilityIdentifier ?? "")
        }
        set {
            self.accessibilityIdentifier = newValue.id
        }
    }
}
