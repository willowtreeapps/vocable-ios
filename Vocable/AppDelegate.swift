//
//  AppDelegate.swift
//  Vocable AAC
//
//  Created by Duncan Lewis on 6/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit
import CoreData
import Combine
import AVFoundation
import VocableListenCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? {
        get {
            gazeableWindow
        }
        // swiftlint:disable unused_setter_value
        set {

        }
    }

    // This is to silence the console warning "The app delegate must implement the window property if it wants to use a main storyboard file"
    // It appears to complain if the window property is not explicitly typed as UIWindow
    private lazy var gazeableWindow = HeadGazeWindow(frame: UIScreen.main.bounds)

    var gazeTrackingWindow: UIHeadGazeTrackingWindow?
    var cursorWindow: UIHeadGazeCursorWindow? {
        didSet {
            gazeableWindow.cursorView = cursorWindow?.cursorViewController.virtualCursorView
        }
    }

    private var disposables: [AnyCancellable] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if !AppConfig.isHeadTrackingSupported {
            AppConfig.isHeadTrackingEnabled = false
        }

        if LaunchArguments.contains(.resetAppDataOnLaunch) {
            print("-resetAppDataOnLaunch detected, resetting app data")
            let resetController = AppResetController()
            if resetController.performReset() {
                print("\t...Succeeded")
            } else {
                print("\t...Reset failed")
            }
        }

        if LaunchArguments.contains(.disableAnimations) {
            print("-disableAnimations detected")
            UIView.setAnimationsEnabled(false)
        }

        Analytics.shared.track(.appOpened)

        // Ensure that the persistent store has the current
        // default presets before presenting UI
        performPersistenceMigrationForCurrentLanguage()
        
        addObservers()

        // Warm up the speech engine to prevent lag on first invocation
        AVSpeechSynthesizer.shared.speak("", language: "en")

        application.isIdleTimerDisabled = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(localeDidChange(_:)),
                                               name: NSLocale.currentLocaleDidChangeNotification,
                                               object: nil)

        AppConfig.$isHeadTrackingEnabled.receive(on: DispatchQueue.main).sink { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.installTrackingWindowsIfNeeded()
            } else {
                self.removeTrackingWindowsIfNeeded()
            }
        }.store(in: &disposables)

        _ = SpeechRecognitionController.shared

        AppConfig.listeningMode.$isEnabled
            .removeDuplicates()
            .sink { isEnabled in
                if #available(iOS 14.0, *), isEnabled {
                    VLClassifier.prepare()
                }
            }.store(in: &disposables)

        return true
    }

    private func installTrackingWindowsIfNeeded() {
        if gazeTrackingWindow == nil {
            gazeTrackingWindow = UIHeadGazeTrackingWindow(frame: UIScreen.main.bounds)
            gazeTrackingWindow?.windowLevel = UIWindow.Level(rawValue: -1)
            gazeTrackingWindow?.isHidden = false
        }
        if cursorWindow == nil {
            cursorWindow = UIHeadGazeCursorWindow(frame: UIScreen.main.bounds)
            cursorWindow?.windowLevel = UIWindow.Level(rawValue: 1)
            cursorWindow?.isHidden = false
        }
    }

    private func removeTrackingWindowsIfNeeded() {
        gazeTrackingWindow?.isHidden = true
        gazeTrackingWindow = nil

        cursorWindow?.isHidden = true
        cursorWindow = nil
    }

    @objc
    private func localeDidChange(_ note: Notification?) {
        performPersistenceMigrationForCurrentLanguage()
    }

    private func performPersistenceMigrationForCurrentLanguage() {
        let migrationController = PersistenceMigrationController()
        migrationController.performMigrationForCurrentLanguagePreferences()
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(headTrackingDisabled(_:)), name: .headTrackingDisabled, object: nil)
    }
    
    @objc private func applicationDidLoseGaze(_ sender: Any?) {
         gazeableWindow.presentHeadTrackingErrorToastIfNeeded()
    }

    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        ToastWindow.shared.dismissPersistentWarning()
    }
    
    @objc private func headTrackingDisabled(_ sender: Any?) {
        ToastWindow.shared.dismissPersistentWarning()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Analytics.shared.track(.appOpened)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Analytics.shared.track(.appBackgrounded)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Analytics.shared.track(.appClosed)
    }
}
