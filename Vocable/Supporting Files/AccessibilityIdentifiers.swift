//
//  AccessibilityIdentifiers.swift
//  Vocable
//
//  Created by Rhonda Oglesby on 4/29/22.
//

import Foundation

public struct AccessibilityIdentifiers {

    public struct Shared {
        public struct KeyboardButton { public static let id = "shared-keyboard-button" }
        public struct SettingsButton { public static let id = "shared-settings-button" }
        public struct BackButton { public static let id = "shared-back-button" }
        public struct TitleLabel { public static let id = "shared-title-label" }
        
        public struct Pagination {
            public struct PreviousButton { public static let id = "shared-pagination-previous-button" }
            public struct NextButton { public static let id = "shared-pagination-next-button" }
            public struct PageLabel { public static let id = "shared-pagination-page-label" }
        }
    }

    public struct Root {
        public struct OutputText { public static let id = "root-output-text" }
        
        public struct Categories {
            public struct PreviousButton { public static let id = "root-categories-previous-button" }
            public struct NextButton { public static let id = "root-categories-next-button" }
        }

//        public struct NumericCategory {
//            public struct ContinueButton { public static let id = "root-numeric-category-" }
//        }
    }

    public struct Settings {
        public struct CloseSettingsButton { public static let id = "settings-close-settings-button" }
        public struct CategoriesAndPhrasesButton { public static let id = "settings-categories-and-phrases-button" }
        public struct TimingAndSensitivityButton { public static let id = "settings-timing-and-sensitivity-button" }
        public struct ResetAppSettingsButton { public static let id = "settings-reset-app-settings-button" }
        public struct SelectionModeButton { public static let id = "settings-selection-mode-button" }
        public struct TuneCursorButton { public static let id = "settings-tune-cursor-button" }
        public struct PrivacyPolicyButton { public static let id = "settings-privacy-policy-button" }
        public struct ContactDevelopersButton { public static let id = "settings-contact-developers-button" }

        public struct EditCategories {
            public struct AddCategoryButton { public static let id = "settings-edit-categories-add-category-button" }
            public struct CategoryButton { public static let id = "settings-edit-categories-category-button" }
            public struct MoveUpButton { public static let id = "settings-edit-categories-move-up-button" }
            public struct MoveDownButton { public static let id = "settings-edit-categories-move-down-button" }
        }

        public struct EditPhrases {
            public struct AddLocationButton { public static let id = "settings-edit-phrases-" }
        }

        public struct TimingAndSensitivity {
            public struct DecreaseHoverTimeButton { public static let id = "settings-timing-and-sensitivity-decrease-hover-time-button" }
            public struct IncreaseHoverTimeButton { public static let id = "settings-timing-and-sensitivity-increase-hover-time-button" }
            public struct LowSensitivityButton { public static let id = "settings-timing-and-sensitivity-low-sensitivity-button" }
            public struct MediumSensitivityButton { public static let id = "settings-timing-and-sensitivity-medium-sensitivity-button" }
            public struct HighSensitivityButton { public static let id = "settings-timing-and-sensitivity-high-sensitivity-button" }
        }

        public struct SelectionMode {
            public struct HeadTrackingToggle { public static let id = "settings-selection-mode-head-tracking-toggle" }
        }
    }
}
