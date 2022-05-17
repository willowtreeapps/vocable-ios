//
//  AccessibilityID+Root.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID {
    public struct root {
        public static let outputText: AccessibilityID = "root-output-text"
        public static let categoryBackButton: AccessibilityID = "root-category-back-button"
        public static let categoryForwardButton: AccessibilityID = "root-category-forward-button"
        private init() {}
    }
}
