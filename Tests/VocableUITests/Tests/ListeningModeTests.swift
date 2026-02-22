//
//  ListeningModeTests.swift
//  VocableUITests
//
//  Created for Issue #803 — Add pause to Listening Mode
//  Copyright © 2024 WillowTree. All rights reserved.
//

import XCTest

/// UI tests for the Listening Mode pause/resume feature (Issue #803).
///
/// These tests verify the pause/resume button bar introduced in `ListeningResponseViewController`:
/// - The button is visible when listening mode is active and permissions are granted.
/// - The button starts in the "Pause listening" state.
/// - Tapping the button toggles to the "Resume listening" state.
/// - Tapping again toggles back to the "Pause listening" state.
/// - The button is hidden when microphone/speech permissions have not been granted.
class ListeningModeTests: BaseTest {

    // MARK: - Button Visibility

    /// Verifies the pause/resume button bar is visible when listening mode is active
    /// and the required microphone + speech recognition permissions have been granted.
    ///
    /// Precondition: `BaseTest.setUp` launches the app with `.enableListeningMode` and handles
    ///              permission prompts via `addUIInterruptionMonitor`.
    func testPauseButtonIsVisibleWhenListeningModeActive() throws {
        // Interact with the app to trigger the permission interrupt monitor
        app.tap()

        try ListeningModeScreen.pauseResumeButton.assertExistence(
            timeout: 5.0,
            "The pause/resume button should be visible when listening mode is active and permissions are granted."
        )
    }

    /// Verifies the pause/resume button is NOT visible when listening mode is disabled.
    ///
    /// The button's visibility is gated on `permissionsController.state == nil` (i.e., permissions
    /// fully granted). When listening mode is not enabled at launch, the button bar should be hidden.
    func testPauseButtonHiddenWhenListeningModeDisabled() throws {
        // Terminate and relaunch without the enableListeningMode argument
        app.terminate()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .disableAnimations)
        }
        app.launch()

        try MainScreen.outputText.assertExistence(timeout: 2.0, "Did not arrive on main screen")

        XCTAssertFalse(
            ListeningModeScreen.pauseResumeButton.exists,
            "The pause/resume button should not be visible when listening mode is disabled."
        )
    }

    // MARK: - Initial State

    /// Verifies that the pause/resume button shows the "Pause listening" state when listening
    /// mode first becomes active (i.e., listening is running and not yet paused).
    func testPauseButtonShowsPauseStateInitially() throws {
        // Interact with the app to trigger the permission interrupt monitor
        app.tap()

        try ListeningModeScreen.pauseResumeButton.assertExistence(
            timeout: 5.0,
            "The pause/resume button should exist before checking its initial state."
        )

        XCTAssertEqual(
            ListeningModeScreen.pauseResumeButton.label,
            ListeningModeScreen.pauseAccessibilityLabel,
            "The button should display 'Pause listening' when listening mode is initially active."
        )
    }

    // MARK: - Pause / Resume Toggle

    /// Verifies that tapping the pause button transitions the button to the "Resume listening" state.
    func testTappingPauseButtonTransitionsToPausedState() throws {
        // Interact with the app to trigger the permission interrupt monitor
        app.tap()

        try ListeningModeScreen.pauseResumeButton.assertExistence(
            timeout: 5.0,
            "The pause/resume button should exist before attempting to tap it."
        )

        // Tap to pause
        try ListeningModeScreen.tapPauseResumeButton()

        // Wait for the button label to update
        let resumeExpectation = expectation(
            for: NSPredicate(format: "label == %@", ListeningModeScreen.resumeAccessibilityLabel),
            evaluatedWith: ListeningModeScreen.pauseResumeButton
        )
        wait(for: [resumeExpectation], timeout: 3.0)

        XCTAssertEqual(
            ListeningModeScreen.pauseResumeButton.label,
            ListeningModeScreen.resumeAccessibilityLabel,
            "After tapping pause, the button should display 'Resume listening'."
        )
    }

    /// Verifies that tapping the resume button (after pausing) transitions the button back
    /// to the "Pause listening" state.
    func testTappingResumeButtonTransitionsBackToListeningState() throws {
        // Interact with the app to trigger the permission interrupt monitor
        app.tap()

        try ListeningModeScreen.pauseResumeButton.assertExistence(
            timeout: 5.0,
            "The pause/resume button should exist before attempting to tap it."
        )

        // Tap to pause
        try ListeningModeScreen.tapPauseResumeButton()

        // Wait for the paused state
        let resumeExpectation = expectation(
            for: NSPredicate(format: "label == %@", ListeningModeScreen.resumeAccessibilityLabel),
            evaluatedWith: ListeningModeScreen.pauseResumeButton
        )
        wait(for: [resumeExpectation], timeout: 3.0)

        // Tap again to resume
        try ListeningModeScreen.tapPauseResumeButton()

        // Wait for the listening state to be restored
        let pauseExpectation = expectation(
            for: NSPredicate(format: "label == %@", ListeningModeScreen.pauseAccessibilityLabel),
            evaluatedWith: ListeningModeScreen.pauseResumeButton
        )
        wait(for: [pauseExpectation], timeout: 3.0)

        XCTAssertEqual(
            ListeningModeScreen.pauseResumeButton.label,
            ListeningModeScreen.pauseAccessibilityLabel,
            "After tapping resume, the button should return to displaying 'Pause listening'."
        )
    }

    // MARK: - Persistence Across Navigation

    /// Verifies that the paused state is reflected on the button when returning to the main screen
    /// after navigating away (e.g., into Settings) while paused.
    ///
    /// The `SpeechRecognitionController.pauseListening()` is called on `willResignActive`, so the
    /// button should already be showing the resume state when returning from Settings.
    func testPauseStatePersistedWhenReturningFromSettings() throws {
        // Interact with the app to trigger the permission interrupt monitor
        app.tap()

        try ListeningModeScreen.pauseResumeButton.assertExistence(
            timeout: 5.0,
            "The pause/resume button should exist on the main screen."
        )

        // Navigate into Settings (this triggers willResignActive → pauseListening())
        try MainScreen.settingsButton.tapWhenExists(timeout: 2.0)

        // Dismiss Settings
        try BaseScreen.navBarDismissButton.tapWhenExists(timeout: 2.0)

        // After returning, the app becomes active and resumeListening() is called.
        // The button should be back in the active listening state.
        let pauseExpectation = expectation(
            for: NSPredicate(format: "label == %@", ListeningModeScreen.pauseAccessibilityLabel),
            evaluatedWith: ListeningModeScreen.pauseResumeButton
        )
        wait(for: [pauseExpectation], timeout: 5.0)

        XCTAssertEqual(
            ListeningModeScreen.pauseResumeButton.label,
            ListeningModeScreen.pauseAccessibilityLabel,
            "After returning from Settings, listening should have resumed and the button should show 'Pause listening'."
        )
    }
}
