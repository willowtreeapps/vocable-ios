// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localization {
  /// Page %1$d of %2$d
  internal static func pagingProgressIndicatorFormat(_ p1: Int, _ p2: Int) -> String {
    return Localization.tr("Localizable", "paging_progress_indicator_format", p1, p2)
  }

  internal enum CategoriesListEditor {
    internal enum Header {
      /// Categories
      internal static let title = Localization.tr("Localizable", "categories_list_editor.header.title")
    }
  }

  internal enum CategoryEditor {
    internal enum Alert {
      internal enum CancelEditingConfirmation {
        /// If you close without saving, your changes will be lost.
        internal static let title = Localization.tr("Localizable", "category_editor.alert.cancel_editing_confirmation.title")
        internal enum Button {
          internal enum Cancel {
            /// Cancel
            internal static let title = Localization.tr("Localizable", "category_editor.alert.cancel_editing_confirmation.button.cancel.title")
          }
          internal enum ConfirmExit {
            /// Confirm
            internal static let title = Localization.tr("Localizable", "category_editor.alert.cancel_editing_confirmation.button.confirm_exit.title")
          }
        }
      }
      internal enum DeleteCategoryConfirmation {
        /// Deleted categories cannot be recovered.
        internal static let title = Localization.tr("Localizable", "category_editor.alert.delete_category_confirmation.title")
        internal enum Button {
          internal enum Cancel {
            /// Cancel
            internal static let title = Localization.tr("Localizable", "category_editor.alert.delete_category_confirmation.button.cancel.title")
          }
          internal enum Remove {
            /// Remove
            internal static let title = Localization.tr("Localizable", "category_editor.alert.delete_category_confirmation.button.remove.title")
          }
        }
      }
      internal enum DeletePhraseConfirmation {
        /// Deleted phrases cannot be recovered.
        internal static let title = Localization.tr("Localizable", "category_editor.alert.delete_phrase_confirmation.title")
        internal enum Button {
          internal enum Cancel {
            /// Cancel
            internal static let title = Localization.tr("Localizable", "category_editor.alert.delete_phrase_confirmation.button.cancel.title")
          }
          internal enum Delete {
            /// Remove
            internal static let title = Localization.tr("Localizable", "category_editor.alert.delete_phrase_confirmation.button.delete.title")
          }
        }
      }
    }
    internal enum Detail {
      internal enum Button {
        internal enum EditPhrases {
          /// Edit Phrases
          internal static let title = Localization.tr("Localizable", "category_editor.detail.button.edit_phrases.title")
        }
        internal enum RemoveCategory {
          /// Remove Category
          internal static let title = Localization.tr("Localizable", "category_editor.detail.button.remove_category.title")
        }
        internal enum RenameCategory {
          /// Rename Category
          internal static let title = Localization.tr("Localizable", "category_editor.detail.button.rename_category.title")
        }
        internal enum ShowCategory {
          /// Show Category
          internal static let title = Localization.tr("Localizable", "category_editor.detail.button.show_category.title")
        }
      }
    }
    internal enum Toast {
      internal enum ChangesSaved {
        /// Changes saved
        internal static let title = Localization.tr("Localizable", "category_editor.toast.changes_saved.title")
      }
      internal enum SuccessfullySaved {
        /// Changes Saved
        internal static let title = Localization.tr("Localizable", "category_editor.toast.successfully_saved.title")
      }
    }
  }

  internal enum Debug {
    internal enum Assertion {
      /// No presets found
      internal static let presetsFileNotFound = Localization.tr("Localizable", "debug.assertion.presets_file_not_found")
    }
  }

  internal enum EmptyState {
    internal enum Button {
      /// Add Phrase
      internal static let title = Localization.tr("Localizable", "empty_state.button.title")
    }
    internal enum Header {
      /// You don't have any phrases saved yet.
      internal static let title = Localization.tr("Localizable", "empty_state.header.title")
    }
  }

  internal enum GazeSettings {
    internal enum Alert {
      internal enum DisableHeadTrackingConfirmation {
        /// Turning off head tracking will make the app touch mode only. Would you like to continue?
        internal static let title = Localization.tr("Localizable", "gaze_settings.alert.disable_head_tracking_confirmation.title")
        internal enum Button {
          internal enum Cancel {
            /// Cancel
            internal static let title = Localization.tr("Localizable", "gaze_settings.alert.disable_head_tracking_confirmation.button.cancel.title")
          }
          internal enum Confirm {
            /// Continue
            internal static let title = Localization.tr("Localizable", "gaze_settings.alert.disable_head_tracking_confirmation.button.confirm.title")
          }
        }
      }
    }
  }

  internal enum GazeTracking {
    internal enum Error {
      internal enum ExcessiveHeadDistance {
        /// Please move closer to the device.
        internal static let title = Localization.tr("Localizable", "gaze_tracking.error.excessive_head_distance.title")
      }
    }
  }

  internal enum ListeningMode {
    internal enum EmptyState {
      internal enum ActivelyListening {
        /// When someone asks a question out loud, Vocable will offer quick response options.
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.actively_listening.message")
        /// Listening...
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.actively_listening.title")
      }
      internal enum FreeResponse {
        /// Not sure what to suggest. Please use the keyboard or select an existing phrase to reply.
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.free_response.message")
        /// Sounds complicated
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.free_response.title")
      }
      internal enum MicrophonePermissionDenied {
        /// Open Settings
        internal static let action = Localization.tr("Localizable", "listening_mode.empty_state.microphone_permission_denied.action")
        /// Vocable needs to use the microphone to enable Listening Mode. Please enable microphone access in the system Settings app.
        /// 
        /// You can also disable Listening Mode to hide this category in Vocable's settings.
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.microphone_permission_denied.message")
        /// Microphone Access
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.microphone_permission_denied.title")
      }
      internal enum MicrophonePermissionUndetermined {
        /// Grant Access
        internal static let action = Localization.tr("Localizable", "listening_mode.empty_state.microphone_permission_undetermined.action")
        /// Vocable needs microphone access to enable Listening Mode. The button below presents an iOS permission dialog that Vocable's head tracking cannot interract with.
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.microphone_permission_undetermined.message")
        /// Microphone Access
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.microphone_permission_undetermined.title")
      }
      internal enum SpeechPermissionDenied {
        /// Open Settings
        internal static let action = Localization.tr("Localizable", "listening_mode.empty_state.speech_permission_denied.action")
        /// Vocable needs speech recognition to enable Listening Mode. Please enable speech recognition in the system Settings app.
        /// 
        /// You can also disable Listening Mode to hide this category in Vocable's settings.
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.speech_permission_denied.message")
        /// Speech Recognition
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.speech_permission_denied.title")
      }
      internal enum SpeechPermissionUndetermined {
        /// Grant Access
        internal static let action = Localization.tr("Localizable", "listening_mode.empty_state.speech_permission_undetermined.action")
        /// Vocable needs to request speech permissions to enable Listening Mode. This will present an iOS permission dialog that Vocable's head tracking cannot interract with.
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.speech_permission_undetermined.message")
        /// Speech Recognition
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.speech_permission_undetermined.title")
      }
      internal enum SpeechUnavailable {
        /// Please try again later
        internal static let message = Localization.tr("Localizable", "listening_mode.empty_state.speech_unavailable.message")
        /// Speech services unavailable
        internal static let title = Localization.tr("Localizable", "listening_mode.empty_state.speech_unavailable.title")
      }
    }
  }

  internal enum MainScreen {
    internal enum TextfieldPlaceholder {
      /// Select something below to speak
      internal static let `default` = Localization.tr("Localizable", "main_screen.textfield_placeholder.default")
    }
  }

  internal enum PhraseEditor {
    internal enum Alert {
      internal enum CancelEditingConfirmation {
        /// If you close without saving, your changes will be lost.
        internal static let title = Localization.tr("Localizable", "phrase_editor.alert.cancel_editing_confirmation.title")
        internal enum Button {
          internal enum ContinueEditing {
            /// Continue Editing
            internal static let title = Localization.tr("Localizable", "phrase_editor.alert.cancel_editing_confirmation.button.continue_editing.title")
          }
          internal enum Discard {
            /// Discard
            internal static let title = Localization.tr("Localizable", "phrase_editor.alert.cancel_editing_confirmation.button.discard.title")
          }
        }
      }
      internal enum PhraseNameExists {
        /// This phrase already exists. Would you like to create a duplicate?
        internal static let title = Localization.tr("Localizable", "phrase_editor.alert.phrase_name_exists.title")
        internal enum Cancel {
          /// Cancel
          internal static let button = Localization.tr("Localizable", "phrase_editor.alert.phrase_name_exists.cancel.button")
        }
        internal enum Create {
          /// Create Duplicate
          internal static let button = Localization.tr("Localizable", "phrase_editor.alert.phrase_name_exists.create.button")
        }
      }
    }
    internal enum Toast {
      internal enum SuccessfullySavedToFavorites {
        /// Saved to %@
        internal static func titleFormat(_ p1: Any) -> String {
          return Localization.tr("Localizable", "phrase_editor.toast.successfully_saved_to_favorites.title_format", String(describing: p1))
        }
      }
    }
  }

  internal enum Preset {
    internal enum Category {
      internal enum Add {
        internal enum Phrase {
          /// Add Phrase
          internal static let title = Localization.tr("Localizable", "preset.category.add.phrase.title")
        }
      }
      internal enum Numberpad {
        internal enum Phrase {
          internal enum No {
            /// No
            internal static let title = Localization.tr("Localizable", "preset.category.numberpad.phrase.no.title")
          }
          internal enum Yes {
            /// Yes
            internal static let title = Localization.tr("Localizable", "preset.category.numberpad.phrase.yes.title")
          }
        }
      }
    }
  }

  internal enum RecentsEmptyState {
    internal enum Body {
      /// Start using Vocable to see your most recently used phrases here.
      internal static let title = Localization.tr("Localizable", "recents_empty_state.body.title")
    }
    internal enum Header {
      /// No recently used phrases
      internal static let title = Localization.tr("Localizable", "recents_empty_state.header.title")
    }
  }

  internal enum SelectionMode {
    internal enum Header {
      /// Selection Mode
      internal static let title = Localization.tr("Localizable", "selection_mode.header.title")
    }
  }

  internal enum Settings {
    internal enum Alert {
      internal enum NoEmailConfigured {
        /// Please sign into an account with Mail for %1$@.
        internal static func title(_ p1: Any) -> String {
          return Localization.tr("Localizable", "settings.alert.no_email_configured.title", String(describing: p1))
        }
        internal enum Button {
          internal enum Dismiss {
            /// OK
            internal static let title = Localization.tr("Localizable", "settings.alert.no_email_configured.button.dismiss.title")
          }
        }
      }
      internal enum ResetAppSettingsConfirmation {
        /// Are you sure you want to reset Vocable to default settings? This action cannot be undone.
        internal static let body = Localization.tr("Localizable", "settings.alert.reset_app_settings_confirmation.body")
        internal enum Button {
          internal enum Cancel {
            /// Cancel
            internal static let title = Localization.tr("Localizable", "settings.alert.reset_app_settings_confirmation.button.cancel.title")
          }
          internal enum Confirm {
            /// Reset
            internal static let title = Localization.tr("Localizable", "settings.alert.reset_app_settings_confirmation.button.confirm.title")
          }
        }
      }
      internal enum ResetAppSettingsFailure {
        /// Vocable failed to reset. Please try again or reinstall Vocable if the issue persists.
        internal static let body = Localization.tr("Localizable", "settings.alert.reset_app_settings_failure.body")
        internal enum Button {
          /// OK
          internal static let ok = Localization.tr("Localizable", "settings.alert.reset_app_settings_failure.button.ok")
        }
      }
      internal enum ResetAppSettingsSuccess {
        /// Vocable has been reset successfully.
        internal static let body = Localization.tr("Localizable", "settings.alert.reset_app_settings_success.body")
        internal enum Button {
          /// OK
          internal static let ok = Localization.tr("Localizable", "settings.alert.reset_app_settings_success.button.ok")
        }
      }
      internal enum SurrenderGazeConfirmation {
        /// You're about to leave the Vocable app. You may lose head tracking control.
        internal static let body = Localization.tr("Localizable", "settings.alert.surrender_gaze_confirmation.body")
        internal enum Button {
          internal enum Cancel {
            /// Cancel
            internal static let title = Localization.tr("Localizable", "settings.alert.surrender_gaze_confirmation.button.cancel.title")
          }
          internal enum Confirm {
            /// Confirm
            internal static let title = Localization.tr("Localizable", "settings.alert.surrender_gaze_confirmation.button.confirm.title")
          }
        }
      }
    }
    internal enum Cell {
      internal enum Categories {
        /// Categories and Phrases
        internal static let title = Localization.tr("Localizable", "settings.cell.categories.title")
      }
      internal enum ContactDevelopers {
        /// Contact Developers
        internal static let title = Localization.tr("Localizable", "settings.cell.contact_developers.title")
      }
      internal enum EditUserFavorites {
        /// Edit %@
        internal static func titleFormat(_ p1: Any) -> String {
          return Localization.tr("Localizable", "settings.cell.edit_user_favorites.title_format", String(describing: p1))
        }
      }
      internal enum HeadTracking {
        /// Head Tracking
        internal static let title = Localization.tr("Localizable", "settings.cell.head_tracking.title")
      }
      internal enum ListeningMode {
        /// Listening Mode
        internal static let title = Localization.tr("Localizable", "settings.cell.listening_mode.title")
      }
      internal enum PrivacyPolicy {
        /// Privacy Policy
        internal static let title = Localization.tr("Localizable", "settings.cell.privacy_policy.title")
      }
      internal enum ResetAll {
        /// Reset App Settings
        internal static let title = Localization.tr("Localizable", "settings.cell.reset_all.title")
      }
      internal enum SelectionMode {
        /// Selection Mode
        internal static let title = Localization.tr("Localizable", "settings.cell.selection_mode.title")
      }
      internal enum TimingSensitivity {
        /// Timing and Sensitivity
        internal static let title = Localization.tr("Localizable", "settings.cell.timing_sensitivity.title")
      }
      internal enum TuneCursor {
        /// Tune Cursor
        internal static let title = Localization.tr("Localizable", "settings.cell.tune_cursor.title")
      }
    }
    internal enum Header {
      /// Settings
      internal static let title = Localization.tr("Localizable", "settings.header.title")
    }
    internal enum ListeningMode {
      /// When this shortcut is enabled, anyone can say "Hey, Vocable" to prompt the app to navigate to the listening mode screen.
      internal static let hotwordExplanationFooter = Localization.tr("Localizable", "settings.listening_mode.hotword_explanation_footer")
      /// When listening mode is enabled, anyone can ask a question out loud and Vocable will offer a selection of responses. Vocable supports either/or questions and questions that can be answered with yes, no, or a number.
      internal static let listeningModeExplanationFooter = Localization.tr("Localizable", "settings.listening_mode.listening_mode_explanation_footer")
      /// Listening Mode
      internal static let title = Localization.tr("Localizable", "settings.listening_mode.title")
      internal enum HotWordToggleCell {
        /// "Hey Vocable" shortcut
        internal static let title = Localization.tr("Localizable", "settings.listening_mode.hot_word_toggle_cell.title")
      }
      internal enum ListeningModeToggleCell {
        /// Listening Mode
        internal static let title = Localization.tr("Localizable", "settings.listening_mode.listening_mode_toggle_cell.title")
      }
    }
    internal enum SelectionMode {
      /// This %1$@ on %2$@ %3$@ does not support head tracking.
      /// 
      /// Head tracking is supported on all devices with a %4$@ camera, and on most devices with %6$@.
      internal static func headTrackingUnsupportedFooter(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any, _ p5: Any) -> String {
        return Localization.tr("Localizable", "settings.selection_mode.head_tracking_unsupported_footer", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), String(describing: p5))
      }
    }
  }

  internal enum TextEditor {
    internal enum Alert {
      internal enum CancelEditingConfirmation {
        /// If you close without saving, your changes will be lost.
        internal static let title = Localization.tr("Localizable", "text_editor.alert.cancel_editing_confirmation.title")
        internal enum Button {
          internal enum ContinueEditing {
            /// Continue Editing
            internal static let title = Localization.tr("Localizable", "text_editor.alert.cancel_editing_confirmation.button.continue_editing.title")
          }
          internal enum Discard {
            /// Discard
            internal static let title = Localization.tr("Localizable", "text_editor.alert.cancel_editing_confirmation.button.discard.title")
          }
        }
      }
      internal enum CategoryNameExists {
        /// This category name already exists. Would you like to create a duplicate?
        internal static let title = Localization.tr("Localizable", "text_editor.alert.category_name_exists.title")
        internal enum Cancel {
          /// Cancel
          internal static let button = Localization.tr("Localizable", "text_editor.alert.category_name_exists.cancel.button")
        }
        internal enum Create {
          /// Create Duplicate
          internal static let button = Localization.tr("Localizable", "text_editor.alert.category_name_exists.create.button")
        }
      }
    }
  }

  internal enum TimingAndSensitivity {
    internal enum Button {
      internal enum High {
        /// High
        internal static let title = Localization.tr("Localizable", "timing_and_sensitivity.button.high.title")
      }
      internal enum Low {
        /// Low
        internal static let title = Localization.tr("Localizable", "timing_and_sensitivity.button.low.title")
      }
      internal enum Medium {
        /// Medium
        internal static let title = Localization.tr("Localizable", "timing_and_sensitivity.button.medium.title")
      }
    }
    internal enum Cell {
      internal enum CursorSensitivity {
        /// Cursor Sensitivity
        internal static let title = Localization.tr("Localizable", "timing_and_sensitivity.cell.cursor_sensitivity.title")
      }
      internal enum DwellDuration {
        /// Hover Time
        internal static let title = Localization.tr("Localizable", "timing_and_sensitivity.cell.dwell_duration.title")
      }
    }
    internal enum Header {
      /// Timing and Sensitivity
      internal static let title = Localization.tr("Localizable", "timing_and_sensitivity.header.title")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
