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

class SpeechRecognizerController: NSObject, SFSpeechRecognitionTaskDelegate {

    static let shared = SpeechRecognizerController()

    @Published private(set) var isPaused: Bool = false {
        didSet {
            guard oldValue != isPaused, mode == .transcribing else { return }
            if isPaused {
                AudioEngineController.shared.playEffect(.paused, completion: {})
            } else {
                AudioEngineController.shared.playEffect(.listening, completion: {})
            }
        }
    }

    @Published private(set) var isListening = false

    enum ListeningMode {
        case off
        case hotWord
        case transcribing
    }

    @Published private(set) var mode: ListeningMode = .off {
        didSet {
            print("\(oldValue) -> \(mode)")
            guard oldValue != mode else { return }
            if mode == .transcribing {
                AudioEngineController.shared.playEffect(.listening, completion: {})
            } else if oldValue == .transcribing {
                AudioEngineController.shared.playEffect(.paused, completion: {})
            }
        }
    }

    enum TranscriptionResult {
        case none
        case hotWord
        case partialTranscription(String)
        case finalTranscription(String)
    }

    @Published private(set) var transcription: TranscriptionResult = .none

    private var isTranscriptionPermitted: Bool {
        let recordingIsPermitted = AVAudioSession.sharedInstance().recordPermission == .granted
        let transcriptionIsPermitted = SFSpeechRecognizer.authorizationStatus() == .authorized
        let isPermitted = recordingIsPermitted && transcriptionIsPermitted
        return isPermitted
    }
    
    private let timeoutInterval: TimeInterval = 1.2
    private let hotWordPhrase = "hey vocable"
    private var hotWordEnabledCancellable: AnyCancellable?
    private var listeningModeEnabledCancellable: AnyCancellable?

    private let speechRecognizer: SFSpeechRecognizer? = {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
        recognizer?.supportsOnDeviceRecognition = true
        return recognizer
    }()

    private var bufferCancellable: AnyCancellable?
    private var recognitionTasks = Set<SFSpeechRecognitionTask>()

    private var recognitionBuffers = [SFSpeechRecognitionTask: SFSpeechAudioBufferRecognitionRequest]()

    private var timeout: Timer?

    private var lastErrorDate = Date.distantPast

    @Published private(set) var isHearingWords = false

    override init() {
        super.init()
        registerForApplicationLifecycleEvents()
        hotWordEnabledCancellable = AppConfig.$isHotWordPermitted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.startListeningForHotWordOrDeactivate()
            }

        listeningModeEnabledCancellable = AppConfig.$isListeningModeEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.startListeningForHotWordOrDeactivate()
            }
    }

    func startTranscribing() {
        mode = .transcribing
        startListening()
    }

    func stopTranscribing() {
        startListeningForHotWordOrDeactivate()
    }

    private func countOfRecognitionTasks(matching states: SFSpeechRecognitionTaskState...) -> Int {
        return recognitionTasks.filter { task in
            states.contains(task.state)
        }.count
    }

    private func startListeningForHotWordOrDeactivate() {
        guard AppConfig.isListeningModeEnabled, AppConfig.isHotWordPermitted else {
            mode = .off
            stopListening()
            return
        }
        mode = .hotWord
        startListening()
    }

    private func startListening(resumingFromPause: Bool = false) {

        guard (!isListening && !isPaused) || (resumingFromPause && isListening) else {
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
                        print("START LISTENING...")
                        self.isListening = true
                        self.requestTranscription()
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
        guard isListening else {
            return
        }
        print("STOP LISTENING...")
        isListening = false
        unscheduleListeners()
    }

    private func pauseListening() {
        print("PAUSE LISTENING...")
        isPaused = true
        if isListening {
            unscheduleListeners()
        }
    }

    private func resumeListening() {
        guard isPaused else {
            return
        }
        isPaused = false
        startListening(resumingFromPause: true)
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
    }

    private func startTimer() {
        print("STARTING TIMER...")

        timeout?.invalidate()
        timeout = Timer.scheduledTimer(timeInterval: timeoutInterval,
                                       target: self,
                                       selector: #selector(self.handleTimeout),
                                       userInfo: nil,
                                       repeats: false)
    }

    @objc private func handleTimeout() {
        print("HANDLE TIMEOUT...")

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

        guard bufferCancellable == nil else {
            return
        }
        bufferCancellable = AudioEngineController.shared.$audioBuffer
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                for buffer in self.recognitionBuffers.values {
                    buffer.append($0.buffer)
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

        if mode == .hotWord {
            request.contextualStrings = [hotWordPhrase]
        }

        if let task = speechRecognizer?.recognitionTask(with: request, delegate: self) {
            recognitionBuffers[task] = request
            recognitionTasks.insert(task)
        }

    }

    private func transcribeAgainIfNeeded() {
        guard isListening else {
            return
        }
        requestTranscription()
    }

    //
    // MARK: SFSpeechRecognizerDelegate
    //

    private func normalizedTranscription(from original: String, containedHotWord: inout Bool) -> String? {
        let lowercased = original.lowercased()
        containedHotWord = lowercased.contains(hotWordPhrase.lowercased())
        let partial = original.lowercased()
            .replacingOccurrences(of: hotWordPhrase.lowercased(), with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !partial.isEmpty {
            return partial
        } else {
            return nil
        }
    }

    // Called when the task first detects speech in the source audio
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        // May be useful for UI to indicate when speech is detected (hot word)
        isHearingWords = true
    }

    // Called for all recognitions, including non-final hypothesis
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        var containsHotWord = false
        let transcription = normalizedTranscription(from: transcription.formattedString, containedHotWord: &containsHotWord)
        if mode == .hotWord, containsHotWord {
            self.transcription = .hotWord
            self.mode = .transcribing
        }
        startTimer()
        if let partial = transcription {
            self.transcription = .partialTranscription(partial)
        }
    }

    // Called only for final recognitions of utterances. No more about the utterance will be reported
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        var containsHotWord = false
        let transcription = normalizedTranscription(from: recognitionResult.bestTranscription.formattedString, containedHotWord: &containsHotWord)
        if mode == .hotWord, containsHotWord {
            self.transcription = .hotWord
            self.mode = .transcribing
        }
        print("didFinishRecognition: \(String(describing: transcription))")
        if let phrase = transcription {
            self.transcription = .finalTranscription(phrase)
        }
    }

    // Called when the task is no longer accepting new audio but may be finishing final processing
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        // Potentially buffer the next task? Probably not necessary
        //       - Calling transcribeAgainIfNeeded() will cause this current one to fail
    }

    // Called when the task has been cancelled, either by client app, the user, or the system
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        print("speechRecognitionTaskWasCancelled")
        transcribeAgainIfNeeded()
        recognitionTasks.remove(task)
        recognitionBuffers[task] = nil
    }

    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        print("speechRecognitionTaskDidFinish \(successfully ? "successfully" : "unsuccessfully")")
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
