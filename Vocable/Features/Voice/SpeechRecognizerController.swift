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
    func didReceivePartialTranscription(_ transcription: String)
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

    private static let timeoutInterval: TimeInterval = 1.2

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

        UIApplication.shared.isIdleTimerDisabled = true

        self.timeout?.invalidate()
        self.timeout = Timer.scheduledTimer(timeInterval: SpeechRecognizerController.timeoutInterval,
                                            target: self,
                                            selector: #selector(self.handleTimeout),
                                            userInfo: nil,
                                            repeats: false)

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

        recognitionTask = SpeechRecognizerController.speechRecognizer?.recognitionTask(with: request, delegate: self)
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

    //
    // Called when the task first detects speech in the source audio
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        // TODO: May be useful for UI to indicate when speech is detected (hot word)
    }

    // Called for all recognitions, including non-final hypothesis
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        print("didHypothesizeTranscription")
        DispatchQueue.main.async { [weak self] in
            self?.startTimer()
            self?.delegate?.didReceivePartialTranscription(transcription.formattedString)
        }
    }

    // Called only for final recognitions of utterances. No more about the utterance will be reported
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("didFinishRecognition")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.didGetFinalResult(recognitionResult)
            self.recognitionTask = nil
        }
    }

    // Called when the task is no longer accepting new audio but may be finishing final processing
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        // TODO: Potentially buffer the next task? Probably not necessary
    }

    // Called when the task has been cancelled, either by client app, the user, or the system
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Audio engine did cancel")
            self.stopListening()
            self.delegate?.transcriptionDidCancel()
        }
    }

    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
            print("Audio engine did finish \(successfully ? "successfully" : "unsuccessfully")")
            if !successfully {
                self.stopListening()
                self.delegate?.transcriptionDidCancel()
            }
        }
    }
}

