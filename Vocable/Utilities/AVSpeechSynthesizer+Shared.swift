//
//  AVSpeechSynthesizer+Shared.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/4/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesizer {

    private struct Storage {
        static let shared = AVSpeechSynthesizer()
    }

    static let shared: AVSpeechSynthesizer = {

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        } catch {
            assertionFailure(error.localizedDescription)
        }

        return AVSpeechSynthesizer()
    }()

    func speak(_ string: String, language: String) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language)

        if isSpeaking {
            stopSpeaking(at: .immediate)
        }
        speak(utterance)
    }

}
