//
//  AudioEngineController.swift
//  Vocable
//
//  Created by Chris Stroud on 12/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation

class AudioEngineController {

    static let shared = AudioEngineController()

    @Published private(set) var audioBuffer: (buffer: AVAudioPCMBuffer, timestamp: AVAudioTime)?

    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()

    private var registeredSpeechControllers = Set<SpeechRecognizerController>() {
        didSet {
            updateAudioSession()
        }
    }

    private init() {
        setupRouteChangeNotifications()
        updateAudioSession()
        updateInputNodeTapIfNeeded()
    }

    @objc private func handleRouteChange(notification: Notification) {
        updateInputNodeTapIfNeeded()
    }

    private func setupRouteChangeNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: .AVAudioEngineConfigurationChange,
                       object: nil)
    }

    private var installedTapFormat: AVAudioFormat?
    private func updateInputNodeTapIfNeeded() {
        let bus = 0
        let node = audioEngine.inputNode
        let currentRecordingFormat = node.outputFormat(forBus: bus)

        if let installedFormat = installedTapFormat, installedFormat == currentRecordingFormat {
            return
        }

        node.removeTap(onBus: bus)
        node.installTap(onBus: bus, bufferSize: 1024, format: currentRecordingFormat) { [weak self] buffer, timestamp in
            self?.audioBuffer = (buffer: buffer, timestamp: timestamp)
        }

        installedTapFormat = currentRecordingFormat
        audioEngine.prepare()
    }

    func register(speechRecognizer: SpeechRecognizerController) {
        registeredSpeechControllers.insert(speechRecognizer)
    }

    func unregister(speechRecognizer: SpeechRecognizerController) {
        registeredSpeechControllers.remove(speechRecognizer)
    }

    private func updateAudioSession() {
        do {
            if registeredSpeechControllers.isEmpty {
                try audioSession.setCategory(.playback, mode: .spokenAudio)
                if audioEngine.isRunning {
                    audioEngine.stop()
                }
            } else {
                try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)
                if !audioEngine.isRunning {
                    try audioEngine.start()
                }
            }
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            assertionFailure("Failed to activate audio session: \(error)")
        }
    }
    
}
