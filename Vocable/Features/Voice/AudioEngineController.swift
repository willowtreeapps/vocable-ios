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

    private var registeredSpeechControllers = Set<SpeechRecognizerController>() {
        didSet {
            updateAudioSession()
        }
    }

    private init() {
        setupRouteChangeNotifications()
        updateInputNodeTapIfNeeded()
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
    private func updateInputNodeTapIfNeeded() {

        let bus = 0
        let node = audioEngine.inputNode
        let micInputFormat = node.outputFormat(forBus: bus)

        if let installedFormat = installedTapFormat, installedFormat == micInputFormat {
            return
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
                var error: NSError? = nil

                var haveData = false
                let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
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
