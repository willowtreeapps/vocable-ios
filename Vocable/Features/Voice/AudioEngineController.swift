//
//  AudioEngineController.swift
//  Vocable
//
//  Created by Chris Stroud on 12/17/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

class AudioEngineController {

    static let shared = AudioEngineController()

    @Published private(set) var audioBuffer: (buffer: AVAudioPCMBuffer, timestamp: AVAudioTime)?

    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private let conversionQueue = DispatchQueue(label: "SpeechConversion")

    private var registeredSpeechControllers = Set<SpeechRecognizerController>()

    private init() {
        setupRouteChangeNotifications()
        updateAudioSession()
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

    @discardableResult
    private func updateInputNodeTapIfNeeded() -> Bool {

        let hasRecordPermission = AVAudioSession.sharedInstance().recordPermission == .granted
        guard hasRecordPermission else {
            return false
        }

        let node = audioEngine.inputNode
        let bus = 0
        let micInputFormat = node.inputFormat(forBus: bus)

        if micInputFormat.sampleRate == 0 {
            print("Audio engine input node sample rate 0. Cannot proceed.")
            return false
        }

        if let installedFormat = installedTapFormat, installedFormat == micInputFormat {
            return true
        }

        let speechInputFormat = SFSpeechAudioBufferRecognitionRequest().nativeAudioFormat
        let formatConverter = AVAudioConverter(from: micInputFormat, to: speechInputFormat)!

        node.removeTap(onBus: bus)
        node.installTap(onBus: bus, bufferSize: 1024, format: micInputFormat) { [weak self] buffer, timestamp in
            self?.conversionQueue.async {
                let frameCapacity = AVAudioFrameCount(micInputFormat.sampleRate * 2.0)
                guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: speechInputFormat, frameCapacity: frameCapacity) else {
                    return
                }
                var error: NSError?

                var haveData = false
                let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
                    if haveData {
                        outStatus.pointee = .noDataNow
                        return nil
                    }
                    outStatus.pointee = .haveData
                    haveData = true
                    return buffer
                }

                formatConverter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)

                if let error = error {
                    assertionFailure(error.localizedDescription)
                } else {
                    self?.audioBuffer = (buffer: convertedBuffer, timestamp: timestamp)
                }
            }
        }

        installedTapFormat = micInputFormat
        audioEngine.prepare()
        return true
    }

    func register(speechRecognizer: SpeechRecognizerController, completion: @escaping (Bool) -> Void) {
        registeredSpeechControllers.insert(speechRecognizer)

        // Give the audio engine a chance to warm up.
        // This is a prospective fix for the output bus not being available yet.
        // The extra dispatch may be unnecessary.
        DispatchQueue.main.async { [weak self] in
            let result = self?.updateAudioSession() ?? false
            completion(result)
        }
    }

    func unregister(speechRecognizer: SpeechRecognizerController) {
        registeredSpeechControllers.remove(speechRecognizer)
        updateAudioSession()
    }

    @discardableResult
    private func updateAudioSession() -> Bool {

        do {

            if registeredSpeechControllers.isEmpty {
                if audioEngine.isRunning {
                    audioEngine.stop()
                }
                try audioSession.setCategory(.playback, mode: .spokenAudio)
            } else {

                try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)

                if updateInputNodeTapIfNeeded() {
                    if !audioEngine.isRunning {
                        try audioEngine.start()
                    }
                } else {

                    // This is not the desired path if speech controllers are
                    // registered, but it ensures the audio session will at least
                    // be prepared for speech synthesis
                    try audioSession.setCategory(.playback, mode: .spokenAudio)
                    return false
                }
            }
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            assertionFailure("Failed to activate audio session: \(error)")
            return false
        }
        return true
    }
    
}
