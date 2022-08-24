//
//  AccessibilityID+Root.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID {
    public enum root {
        public static let outputText: AXElement = "root-output-text"
        public static let categoryBackButton: AXElement = "root-category-back-button"
        public static let categoryForwardButton: AXElement = "root-category-forward-button"
        public static let addPhraseButton: AXElement = "root-add-phrase-button"
    }
}
