//
//  ListeningModeScreen.swift
//  VocableUITests
//
//  Created for Issue #803 — Add pause to Listening Mode
//  Copyright © 2024 WillowTree. All rights reserved.
//

import XCTest

class ListeningModeScreen: BaseScreen {

    // MARK: - Screen Elements

    /// The pause/resume toggle button shown in the listening mode bar.
    static let pauseResumeButton = XCUIApplication().buttons[.settings.listeningMode.pauseListeningButton]

    // MARK: - Accessibility Labels

    /// The accessibility label set on the button when listening is active (not paused).
    static let pauseAccessibilityLabel = "Pause listening"

    /// The accessibility label set on the button when listening is paused.
    static let resumeAccessibilityLabel = "Resume listening"

    // MARK: - Navigation

    /// Navigates to the Listening Mode category from the main screen by locating and selecting the
    /// "Listen" category cell. Once selected, the `ListeningResponseViewController` is presented
    /// which contains the pause/resume bar.
    @discardableResult
    static func navigateToListeningModeCategory(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Bool {
        return MainScreen.locateAndSelectDestinationCategory(.listen)
    }

    /// Navigates to the Listening Mode settings screen from the main screen.
    static func navigateToListeningModeSettings(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try MainScreen.settingsButton.tapWhenExists(timeout: 2.0, file: file, line: line)
        try XCUIApplication().cells[.settings.listeningModeCell].tapWhenExists(timeout: 2.0, file: file, line: line)
    }

    /// Taps the pause/resume button.
    static func tapPauseResumeButton(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        try pauseResumeButton.tapWhenExists(timeout: 2.0, file: file, line: line)
    }

    /// Returns true if the listening mode button is currently showing the "Pause" state.
    static var isInPauseState: Bool {
        pauseResumeButton.label == pauseAccessibilityLabel
    }

    /// Returns true if the listening mode button is currently showing the "Resume" state.
    static var isInResumeState: Bool {
        pauseResumeButton.label == resumeAccessibilityLabel
    }
}
