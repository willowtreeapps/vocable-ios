//
//  SpeechRecognitionController.swift
//  Vocable
//
//  Created by Steve Foster on 12/15/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Speech
import Combine

class SpeechRecognitionController: NSObject, SFSpeechRecognitionTaskDelegate, SFSpeechRecognizerDelegate {

    enum AudioPermission {
        case speech
        case microphone
    }

    static let shared = SpeechRecognitionController()

    @Published private(set) var isAvailable: Bool = true

    @Published private(set) var isPaused: Bool = false {
        didSet {
            guard oldValue != isPaused, mode == .transcribing else { return }
            if isPaused {
                soundEffectSubject.send(.paused)
            } else {
                soundEffectSubject.send(.listening)
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
            guard oldValue != mode else { return }
            if mode == .transcribing {
                soundEffectSubject.send(.listening)
            } else if oldValue == .transcribing {
                soundEffectSubject.send(.paused)
            }
        }
    }

    enum TranscriptionResult: Equatable {
        case none
        case hotWord
        case partialTranscription(String)
        case finalTranscription(String)
    }

    @Published private(set) var transcription: TranscriptionResult = .none

    @Published private(set) var microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
    @Published private(set) var speechPermissionStatus = SFSpeechRecognizer.authorizationStatus()

    private var isTranscriptionPermitted: Bool {
        let recordingIsPermitted = AVAudioSession.sharedInstance().recordPermission == .granted
        let transcriptionIsPermitted = SFSpeechRecognizer.authorizationStatus() == .authorized
        let isPermitted = recordingIsPermitted && transcriptionIsPermitted
        return isPermitted
    }
    
    private let timeoutInterval: TimeInterval = 1.2

    // ASR hears what it hears, this regex is just trying to catch common errors
    private let hotWordFirstComponentRegex = "(hey|he|she|a|i)"
    private lazy var hotWordPartialMatchRegex = "^\\s*\(hotWordFirstComponentRegex)\\s*$"
    private lazy var hotWordRegex = "(\(hotWordFirstComponentRegex) (voc|book|fuck)able)|((re|in)vocable)"
    private let hotWordIntendedPhrase = "hey vocable"

    private var hotWordEnabledCancellable: AnyCancellable?

    private lazy var speechRecognizer: SFSpeechRecognizer? = {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
        recognizer?.supportsOnDeviceRecognition = true
        recognizer?.delegate = self
        return recognizer
    }()

    private var bufferCancellable: AnyCancellable?
    private var recognitionTasks = Set<SFSpeechRecognitionTask>()

    private var recognitionBuffers = [SFSpeechRecognitionTask: SFSpeechAudioBufferRecognitionRequest]()

    private var timeout: Timer?

    private var lastErrorDate = Date.distantPast

    // When accepting permissions for speech/microphone, the engine is paused due to
    // app lifecycle notifications. This flow causes the "listening" sound to happen
    // twice. Removing duplicate values via Combine gives us a quick fix that doesn't require
    // messing with other state variables.
    private var soundEffectSubject = PassthroughSubject<SoundEffect, Never>()
    private var soundEffectPlaybackCancellable: AnyCancellable?

    @Published private(set) var isHearingWords = false

    var deviceSupportsSpeech: Bool {
        return speechPermissionStatus != .restricted
    }

    private var isAuthorizedToTranscribe: Bool {
        let micIsAuthorized = microphonePermissionStatus == .granted
        let speechIsAuthorized = speechPermissionStatus == .authorized
        return micIsAuthorized && speechIsAuthorized
    }

    override init() {
        super.init()

        updatePermissionStatuses()
        
        registerForApplicationLifecycleEvents()

        isAvailable = speechRecognizer?.isAvailable ?? false

        hotWordEnabledCancellable = Publishers.Merge(AppConfig.$isHotWordPermitted, AppConfig.$isListeningModeEnabled)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.startListeningForHotWordOrDeactivate()
            }

        soundEffectPlaybackCancellable = soundEffectSubject
            .removeDuplicates()
            .sink { newValue in
                AudioEngineController.shared.playEffect(newValue, completion: {})
            }
    }

    func startTranscribing(requestPermission: AudioPermission? = nil) {
        guard isAuthorizedToTranscribe || requestPermission != nil else { return }
        startListening(mode: .transcribing, requestablePermission: requestPermission)
    }

    func stopTranscribing() {
        transcription = .none
        startListeningForHotWordOrDeactivate()
    }

    private func countOfRecognitionTasks(matching states: SFSpeechRecognitionTaskState...) -> Int {
        return recognitionTasks.filter { task in
            states.contains(task.state)
        }.count
    }

    private func startListeningForHotWordOrDeactivate() {
        guard isAvailable, AppConfig.isListeningModeEnabled, AppConfig.isHotWordPermitted, deviceSupportsSpeech, isAuthorizedToTranscribe else {
            stopListening()
            return
        }
        startListening(mode: .hotWord)
    }

    private func updatePermissionStatuses() {
        self.speechPermissionStatus = SFSpeechRecognizer.authorizationStatus()
        self.microphonePermissionStatus = AVAudioSession.sharedInstance().recordPermission
    }

    private func startListening(mode: ListeningMode, resumingFromPause: Bool = false, requestablePermission: AudioPermission? = nil) {

        guard !isPaused && ((mode != self.mode) || (resumingFromPause && isListening)) else {
            return
        }

        cancelActiveRecognitionTasks()

        if SFSpeechRecognizer.authorizationStatus() == .notDetermined {
            if requestablePermission != .speech {
                return
            }
        }
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }

            self.updatePermissionStatuses()

            switch authStatus {
            case .authorized:
                let audioSession = AVAudioSession.sharedInstance()
                if audioSession.recordPermission == .undetermined {
                    if requestablePermission != .microphone {
                        return
                    }
                }
                audioSession.requestRecordPermission { canRecord in
                    guard canRecord else {
                        print("Recording permission denied")
                        self.isListening = false
                        self.mode = .off
                        return
                    }
                    self.updatePermissionStatuses()

                    guard self.isAvailable else {
                        return
                    }

                    let audioController = AudioEngineController.shared

                    audioController.register(speechRecognizer: self, completion: { didInit in
                        guard didInit else {
                            print("Audio engine failed to initialize")
                            self.isListening = false
                            self.mode = .off
                            return
                        }
                        print("START LISTENING...")
                        self.isListening = true
                        self.mode = mode
                        self.requestTranscription()
                    })
                }

            case .denied:
                print("Speech permission denied")
                self.isListening = false
                self.mode = .off
            default:
                print("Speech permission unknown")
                self.isListening = false
                self.mode = .off
            }
        }
    }

    func stopListening() {
        guard isListening else {
            return
        }
        print("STOP LISTENING...")
        cancelTimer(reason: "stopListening() invoked")
        mode = .off
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
        startListening(mode: mode, resumingFromPause: true)
    }

    private func cancelActiveRecognitionTasks() {
        for task in recognitionTasks {
            task.finish()
        }
        recognitionTasks.removeAll()
    }

    private func unscheduleListeners() {
        cancelActiveRecognitionTasks()

        let audioController = AudioEngineController.shared
        func unregister() {
            audioController.unregister(speechRecognizer: self)
        }
    }

    private func startTimer(customTimeout: TimeInterval? = nil) {
        print("STARTING TIMER...")

        timeout?.invalidate()
        timeout = Timer.scheduledTimer(timeInterval: customTimeout ?? timeoutInterval,
                                       target: self,
                                       selector: #selector(self.handleTimeout),
                                       userInfo: nil,
                                       repeats: false)
    }

    private func cancelTimer(reason: String? = nil) {
        if let timer = timeout {
            timer.invalidate()
            let reasonString: String
            if let reason = reason {
                reasonString = ": \(reason)"
            } else {
                reasonString = ""
            }
            print("TIMER CANCELLED" + reasonString)
        }
        timeout = nil
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

        // Making this always be available as a contextual string
        // because the person speaking may not be able to see the
        // device screen to recognize what state we're in
        request.contextualStrings = [hotWordIntendedPhrase]

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
        let lowercased = original.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        let regex = try! NSRegularExpression(pattern: hotWordRegex, options: [.anchorsMatchLines])
        let matches = regex.matches(in: lowercased, options: [], range: NSRange(lowercased.startIndex..<lowercased.endIndex, in: lowercased))

        // Check for a full hotword match
        guard let _range = matches.last?.range, let hotWordRange = Range(_range, in: lowercased) else {
            containedHotWord = false

            // If we have a WIP potential hot word, wait until we have the next
            // chunk of the utterance before allowing it to propagate to the UI
            let partialRegex = try! NSRegularExpression(pattern: hotWordPartialMatchRegex, options: [.anchorsMatchLines])
            let partialMatches = partialRegex.matches(in: lowercased, options: [], range: NSRange(lowercased.startIndex..<lowercased.endIndex, in: lowercased))
            if partialMatches.isEmpty {
                return lowercased
            }
            return nil
        }
        containedHotWord = true

        // Anything preceeding the hotword can be discarded
        var partial = ""
        if hotWordRange.upperBound < lowercased.endIndex {
            partial = String(lowercased.suffix(from: hotWordRange.upperBound))
        }
        partial = partial.trimmingCharacters(in: .whitespacesAndNewlines)
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

        cancelTimer(reason: "New hypothesis \"\(transcription.formattedString)\"")

        var containsHotWord = false
        let transcription = normalizedTranscription(from: transcription.formattedString, containedHotWord: &containsHotWord)
        if mode == .hotWord, containsHotWord {
            self.transcription = .hotWord
            self.mode = .transcribing

            // Wait a bit longer since the person speaking
            // may pause for the UI transition to complete
            startTimer(customTimeout: timeoutInterval * 2)
        } else {
            startTimer()
        }

        if self.mode == .transcribing, let partial = transcription {
            self.transcription = .partialTranscription(partial)
        }
    }

    // Called only for final recognitions of utterances. No more about the utterance will be reported
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {

        var containsHotWord = false
        let transcription = normalizedTranscription(from: recognitionResult.bestTranscription.formattedString, containedHotWord: &containsHotWord)
        print("didFinishRecognition: \(String(describing: transcription))")

        cancelTimer(reason: "Recognition finished")

        if mode == .hotWord, containsHotWord {
            self.transcription = .hotWord
            self.mode = .transcribing
        }

        if self.mode == .transcribing, let phrase = transcription {
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
        cancelTimer(reason: "recognition task was cancelled")
        transcribeAgainIfNeeded()
        recognitionTasks.remove(task)
        recognitionBuffers[task] = nil
    }

    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {

        cancelTimer(reason: "recognition task finished")

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
    // MARK: SFSpeechRecognizerDelegate
    //

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        isAvailable = available

        if isAvailable {
            switch mode {
            case .hotWord, .off:
                startListeningForHotWordOrDeactivate()
            case .transcribing:
                startListening(mode: .transcribing)
            }
        } else {
            stopListening()
            transcription = .none
        }
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
        updatePermissionStatuses()
        if AppConfig.isVoiceExperimentEnabled {
            resumeListening()
        }
    }
}
