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
    func didReceiveRequiredPhrase()
    func transcriptionDidCancel()
}

class SpeechRecognizerController: NSObject, SFSpeechRecognitionTaskDelegate {

    enum ListeningStatus {
        case stopped    // Not listening
        case paused     // Not listening, but will automatically resume once the current interruption ends
        case listening  // Actively listening
    }

    weak var delegate: SpeechRecognizerControllerDelegate?
    var timeoutInterval: TimeInterval = 1.2
    var requiredPhrase: String?

    static private let speechRecognizer: SFSpeechRecognizer? = {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
        recognizer?.supportsOnDeviceRecognition = true
        return recognizer
    }()

    private var bufferCancellable: AnyCancellable?
    private var recognitionTasks = Set<SFSpeechRecognitionTask>()

    private var recognitionBuffers = [SFSpeechRecognitionTask: SFSpeechAudioBufferRecognitionRequest]()

    private var timeout: Timer?

    private var lastErrorDate = Date.distantPast

    @Published private(set) var status: ListeningStatus = .stopped
    @Published private(set) var isHearingWords = false

    private func countOfRecognitionTasks(matching states: SFSpeechRecognitionTaskState...) -> Int {
        return recognitionTasks.filter { task in
            states.contains(task.state)
        }.count
    }

    private let name: String
    private let registerEffect: SoundEffect?
    private let unregisterEffect: SoundEffect?

    init(name: String, registerEffect: SoundEffect? = nil, unregisterEffect: SoundEffect? = nil) {
        self.name = name
        self.registerEffect = registerEffect
        self.unregisterEffect = unregisterEffect
        super.init()
        registerForApplicationLifecycleEvents()
    }

    func startListening() {
        guard status != .listening else {
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

                    let audioController = AudioEngineController.shared

                    audioController.register(speechRecognizer: self, completion: { didInit in
                        guard didInit else {
                            print("Audio engine failed to initialize")
                            return
                        }
                        func actions() {
                            print("[\(self.name)] START LISTENING...")
                            self.status = .listening
                            self.requestTranscription()
                        }

                        if let effect = self.registerEffect {
                            audioController.playEffect(effect, completion: actions)
                        } else {
                            actions()
                        }
                    })
                }

            case .denied:
                assertionFailure("Speech permission denied")
            default:
                assertionFailure("Speech permission unknown")
            }
        }
    }

    func stopListening() {
        guard status != .stopped else {
            return
        }
        print("[\(name)] STOP LISTENING...")
        status = .stopped
        unscheduleListeners()
    }

    private func pauseListening() {
        guard status == .listening else {
            return
        }
        print("[\(name)] PAUSE LISTENING...")
        status = .paused
        unscheduleListeners()
    }

    private func resumeListening() {
        guard status == .paused else {
            return
        }
        startListening()
    }

    private func unscheduleListeners() {
        for task in recognitionTasks {
            task.finish()
        }
        recognitionTasks.removeAll()

        let audioController = AudioEngineController.shared
        func unregister() {
            audioController.unregister(speechRecognizer: self)
        }
        if let effect = unregisterEffect {
            audioController.playEffect(effect, completion: unregister)
        } else {
            unregister()
        }
    }

    private func startTimer() {
        print("[\(name)] STARTING TIMER...")

        timeout?.invalidate()
        timeout = Timer.scheduledTimer(timeInterval: timeoutInterval,
                                       target: self,
                                       selector: #selector(self.handleTimeout),
                                       userInfo: nil,
                                       repeats: false)
    }

    @objc private func handleTimeout() {
        print("[\(name)] HANDLE TIMEOUT...")

        timeout?.invalidate()

        for task in recognitionTasks {
            if let buffer = recognitionBuffers[task] {
                buffer.endAudio()
            }
            task.finish()
        }
        recognitionTasks.removeAll()
    }

    private func prepareSpeechBuffer() {

        if bufferCancellable == nil {
            bufferCancellable = AudioEngineController.shared.$audioBuffer
                .compactMap { $0 }
                .sink { [weak self] in
                    guard let self = self else { return }
                    for buffer in self.recognitionBuffers.values {
                        buffer.append($0.buffer)
                    }
                }
        }
    }

    private func requestTranscription() {

        guard countOfRecognitionTasks(matching: .starting, .running) == 0 else {
            return
        }

        prepareSpeechBuffer()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        request.taskHint = .dictation

        if let phrase = requiredPhrase {
            request.contextualStrings = [phrase]
        }

        if let task = SpeechRecognizerController.speechRecognizer?.recognitionTask(with: request, delegate: self) {
            recognitionBuffers[task] = request
            recognitionTasks.insert(task)
        }

    }

    private func transcribeAgainIfNeeded() {
        guard status == .listening else {
            return
        }
        requestTranscription()
    }

    //
    // MARK: SFSpeechRecognizerDelegate
    //

    // Called when the task first detects speech in the source audio
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        // May be useful for UI to indicate when speech is detected (hot word)
        isHearingWords = true
    }

    // Called for all recognitions, including non-final hypothesis
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        let transcription = transcription.formattedString.lowercased()
        if let requiredPhrase = requiredPhrase, transcription.contains(requiredPhrase.lowercased()) {
            delegate?.didReceiveRequiredPhrase()
        }
        startTimer()
        delegate?.didReceivePartialTranscription(transcription)
    }

    // Called only for final recognitions of utterances. No more about the utterance will be reported
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        let transcription = recognitionResult.bestTranscription.formattedString.lowercased()
        print("[\(name)] didFinishRecognition: \(transcription)")
        if let requiredPhrase = requiredPhrase, transcription.contains(requiredPhrase.lowercased()) {
            delegate?.didReceiveRequiredPhrase()
        }
        delegate?.didGetFinalResult(recognitionResult)
    }

    // Called when the task is no longer accepting new audio but may be finishing final processing
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        // Potentially buffer the next task? Probably not necessary
        //       - Calling transcribeAgainIfNeeded() will cause this current one to fail
    }

    // Called when the task has been cancelled, either by client app, the user, or the system
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("[\(name)] speechRecognitionTaskWasCancelled")
        transcribeAgainIfNeeded()
        recognitionTasks.remove(task)
        recognitionBuffers[task] = nil
    }

    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("[\(name)] speechRecognitionTaskDidFinish \(successfully ? "successfully" : "unsuccessfully")")
        if !successfully {
            // If we get spammed with errors, stop trying to obtain a transcription.
            // This can occur for a number of reasons and it's difficult to enumerate
            // the possible error codes ahead of time
            if Date().timeIntervalSince(lastErrorDate) < 0.05 {
                stopListening()
            }
            lastErrorDate = Date()
        }
        recognitionTasks.remove(task)
        recognitionBuffers[task] = nil
        transcribeAgainIfNeeded()
    }

    //
    // MARK: UIApplication Lifecycle Events
    //

    private func registerForApplicationLifecycleEvents() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(didBecomeActiveNotification(_:)),
                       name: UIApplication.didBecomeActiveNotification,
                       object: nil)

        nc.addObserver(self,
                       selector: #selector(willResignActiveNotification(_:)),
                       name: UIApplication.willResignActiveNotification,
                       object: nil)
    }

    @objc
    private func willResignActiveNotification(_ notification: Notification) {
        if AppConfig.isVoiceExperimentEnabled {
            pauseListening()
        }
    }

    @objc
    private func didBecomeActiveNotification(_ notification: Notification) {
        if AppConfig.isVoiceExperimentEnabled {
            resumeListening()
        }
    }
}
