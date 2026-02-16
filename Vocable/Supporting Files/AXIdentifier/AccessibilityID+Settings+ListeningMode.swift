//
//  AccessibilityID+Settings+ListeningMode.swift
//  Vocable
//
//  Created by Chris Stroud on 8/21/24.
//  Copyright © 2024 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.settings {
    public struct listeningMode {
        public static let listeningModeToggle: AccessibilityID = "listening_mode_toggle"
        public static let hotWordEnabledToggle: AccessibilityID = "hot_word_toggle"
        public static let smartAssistEnabledToggle: AccessibilityID = "use_gpt_toggle"
        public static let pauseListeningButton: AccessibilityID = "listening_mode_pause_button"
        private init() {}
    }
}
