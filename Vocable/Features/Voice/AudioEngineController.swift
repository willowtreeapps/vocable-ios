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

class AudioEngineController: NSObject, AVSpeechSynthesizerDelegate {

    static let shared = AudioEngineController()

    @Published private(set) var audioBuffer: (buffer: AVAudioPCMBuffer, timestamp: AVAudioTime)?

    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private let conversionQueue = DispatchQueue(label: "SpeechConversion")

    private var registeredSpeechControllers = Set<SpeechRecognizerController>()

    private var audioEngineShouldRun = false {
        didSet {
            try? updateAudioEngineRunningState()
        }
    }

    // Could likely be a semaphore or something more thread-safe,
    // but for now this seems adequate
    private var listeningInterruptionCount = 0 {
        didSet {
            try? updateAudioEngineRunningState()
        }
    }

    private var installedTapFormat: AVAudioFormat?

    override init() {
        super.init()
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

    func register(speechRecognizer: SpeechRecognizerController) -> Bool {
        registeredSpeechControllers.insert(speechRecognizer)
        return updateAudioSession()
    }

    func unregister(speechRecognizer: SpeechRecognizerController) {
        registeredSpeechControllers.remove(speechRecognizer)
        updateAudioSession()
    }

    func beginListeningInterruption() {
        listeningInterruptionCount += 1
    }

    func endListeningInterruption() {
        listeningInterruptionCount = max(listeningInterruptionCount - 1, 0)
    }

    private func updateAudioEngineRunningState() throws {

        let interruptionInProgress = listeningInterruptionCount > 0
        if !interruptionInProgress && audioEngineShouldRun {
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
        } else {
            if audioEngine.isRunning {
                audioEngine.pause()
            }
        }
    }

    @discardableResult
    private func updateAudioSession() -> Bool {

        do {

            if registeredSpeechControllers.isEmpty {
                try audioSession.setCategory(.playback, mode: .spokenAudio)
                audioEngineShouldRun = false
            } else {

                try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)

                if updateInputNodeTapIfNeeded() {
                    audioEngineShouldRun = true
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

    // MARK: AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        beginListeningInterruption()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        endListeningInterruption()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        endListeningInterruption()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        endListeningInterruption()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        beginListeningInterruption()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // no-op
    }
}
