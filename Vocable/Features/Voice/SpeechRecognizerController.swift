//
//  SpeechRecognizerController.swift
//  Vocable
//
//  Created by Steve Foster on 12/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Speech
import Combine

protocol SpeechRecognizerControllerDelegate: AnyObject {
    func didGetFinalResult(_ speechRecognitionResult: SFSpeechRecognitionResult)
    func transcriptionDidCancel()
}

class SpeechRecognizerController: NSObject, SFSpeechRecognitionTaskDelegate {

    weak var delegate: SpeechRecognizerControllerDelegate?

    static private let audioEngine = AVAudioEngine()
    static private let speechRecognizer: SFSpeechRecognizer? = {
        let recognizer = SFSpeechRecognizer()
        recognizer?.supportsOnDeviceRecognition = SpeechRecognizerController.shouldUseOnDeviceProcessing
        recognizer?.queue = SpeechRecognizerController.speechRecognitionQueue
        return recognizer
    }()

    private var audioRecorder: AVAudioRecorder?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionBuffer: SFSpeechAudioBufferRecognitionRequest?

    static private let speechRecognitionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()

    private static let _spelledOutFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        return formatter
    }()

    private var timeout: Timer?
    private static let timeoutInterval: TimeInterval = 2.5

    private static var shouldUseOnDeviceProcessing: Bool {
        #if targetEnvironment(simulator)
            return false
        #else
        return true
//            return ProcessInfo.processInfo.environment.keys.contains("UseOnDeviceVoiceProcessing")
        #endif
    }

    func startListening() {
        print("START LISTENING...")

        guard recognitionTask == nil else {
            assertionFailure("Recognition task still running...")
            return
        }

        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
            guard let self = self else { return }
            switch authStatus {
            case .authorized:

                let audioSession = AVAudioSession.sharedInstance()
                audioSession.requestRecordPermission { (canRecord) in
                    guard canRecord else {
                        assertionFailure("Recording permission denied")
                        return
                    }
                    do {
                        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .mixWithOthers)
                        if SyntheticInput.values == nil {
                            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                            self.setupRouteChangeNotifications()
                            self.requestTranscription()
                        } else {
                            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                        }
                        self.startTimer()
                    } catch {
                        assertionFailure("Failed to start audio session: \(error)")
                    }
                }
            default:
                NSLog("Voice recognition not authorized")
            }
        }
    }

    func stopListening() {
        print("STOP LISTENING...")

        audioRecorder?.stop()
        audioRecorder = nil

        recognitionTask?.finish()
        recognitionTask = nil

        SpeechRecognizerController.audioEngine.stop()

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        updateInputNodeTapIfNeeded()
    }

    private func setupRouteChangeNotifications() {
        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: .AVAudioEngineConfigurationChange,
                       object: nil)
    }

    private func startTimer() {
        print("STARTING TIMER...")

        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true

            self.timeout?.invalidate()
            self.timeout = Timer.scheduledTimer(timeInterval: SpeechRecognizerController.timeoutInterval,
                                           target: self,
                                           selector: #selector(self.handleTimeout),
                                           userInfo: nil,
                                           repeats: false)
        }

    }

    @objc private func handleTimeout() {
        print("HANDLE TIMEOUT...")

        timeout?.invalidate()

        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }

        recognitionTask?.finish()
        stopListening()
    }

    private func requestTranscription() {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        recognitionBuffer = request

        updateInputNodeTapIfNeeded()

        do {
            try SpeechRecognizerController.audioEngine.start()
        } catch {
            assertionFailure("Failed to start audio engine: \(error)")
        }

        recognitionTask = SpeechRecognizerController.speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            var isFinal = false

            if let result = result {
                isFinal = result.isFinal
                self?.delegate?.didGetFinalResult(result)
                print("Recognizer RESULT: \(result.bestTranscription.formattedString)")

                if isFinal {
                    print("FINAL Recognizer RESULT: \(result.bestTranscription.formattedString)")
                    self?.recognitionTask = nil
                }
            }

            if error != nil {
                assertionFailure("Recognizer ERROR: \(String(describing: error))")
                self?.recognitionTask = nil
            }
        }

    }

    private var installedTapFormat: AVAudioFormat?
    private func updateInputNodeTapIfNeeded() {
        let bus = 0
        let node = SpeechRecognizerController.audioEngine.inputNode
        let currentRecordingFormat = node.outputFormat(forBus: bus)

        if let installedFormat = installedTapFormat, installedFormat == currentRecordingFormat {
            return
        }

        node.removeTap(onBus: bus)
        node.installTap(onBus: bus, bufferSize: 1024, format: currentRecordingFormat) { [weak self] buffer, _ in
            self?.recognitionBuffer?.append(buffer)
        }

        installedTapFormat = currentRecordingFormat
        SpeechRecognizerController.audioEngine.prepare()
    }

}
