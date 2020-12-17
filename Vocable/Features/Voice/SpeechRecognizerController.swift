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

    static private let speechRecognizer: SFSpeechRecognizer? = {
        let recognizer = SFSpeechRecognizer()
        recognizer?.supportsOnDeviceRecognition = true
        recognizer?.queue = SpeechRecognizerController.speechRecognitionQueue
        return recognizer
    }()

    private var bufferCancellable: AnyCancellable?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionBuffer: SFSpeechAudioBufferRecognitionRequest?

    static private let speechRecognitionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()

    private var timeout: Timer?

    private static let timeoutInterval: TimeInterval = 1.2

    private var isListening = false

    func startListening() {
        print("START LISTENING...")
        isListening = true

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
                    guard SyntheticInput.values == nil else { return }
                    self.requestTranscription()
                }
            default:
                NSLog("Voice recognition not authorized")
            }
        }
    }

    func stopListening() {
        print("STOP LISTENING...")
        isListening = false

        recognitionTask?.finish()
        recognitionTask = nil

        AudioEngineController.shared.unregister(speechRecognizer: self)
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

        recognitionTask?.finish()
        stopListening()
    }

    private func requestTranscription() {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = false
        recognitionBuffer = request

        recognitionTask = SpeechRecognizerController.speechRecognizer?.recognitionTask(with: request, delegate: self)
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
        if isListening {
            requestTranscription()
        }
    }

    // Called when the task has been cancelled, either by client app, the user, or the system
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Audio engine did cancel")
            self.delegate?.transcriptionDidCancel()
        }
        if isListening {
            requestTranscription()
        }
    }

    // Called when recognition of all requested utterances is finished.
    // If successfully is false, the error property of the task will contain error information
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("Audio engine did finish \(successfully ? "successfully" : "unsuccessfully")")
            if !successfully {
                self.delegate?.transcriptionDidCancel()
            }
        }
        if isListening {
            requestTranscription()
        }
    }
}

