//
//  Sounds.swift
//  Vocable
//
//  Created by Chris Stroud on 1/5/21.
//  Copyright © 2021 WillowTree. All rights reserved.
//

import Foundation
import AudioToolbox

enum SoundEffect: String {

    private struct Storage {
        var identifiers = [SoundEffect: SystemSoundID]()
        static var shared = Storage()
    }

    case listening = "Listening"
    case paused = "Paused"

    private var soundID: SystemSoundID? {
        if let effect = Storage.shared.identifiers[self] {
            return effect
        }

        guard let url = Bundle.main.url(forResource: rawValue, withExtension: "wav") else {
            assertionFailure("File not found for name \"\(rawValue)\" of type .wav")
            return nil
        }
        var soundID: SystemSoundID = .zero
        let registrationResult = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        guard registrationResult == .zero else {
            assertionFailure("Failed to register system sound effect (OSStatus \(registrationResult))")
            return nil
        }
        Storage.shared.identifiers[self] = soundID

        var completePlayback: UInt32 = 1
        let propertyResult = AudioServicesSetProperty(kAudioServicesPropertyCompletePlaybackIfAppDies,
                                                      UInt32(MemoryLayout<SystemSoundID>.size),
                                                      &soundID,
                                                      UInt32(MemoryLayout<UInt32>.size),
                                                      &completePlayback)
        guard propertyResult == .zero else {
            assertionFailure("Failed to set kAudioServicesPropertyCompletePlaybackIfAppDies = 1 for sound effect (OSStatus=\(propertyResult)")
            return soundID
        }

        return soundID
    }

    func play() {
        guard let soundID = self.soundID else {
            assertionFailure("No sound ID exists for \"\(rawValue)\"")
            return
        }
        AudioEngineController.shared.beginListeningInterruption()
        AudioServicesPlaySystemSoundWithCompletion(soundID) {
            AudioEngineController.shared.endListeningInterruption()
            print("\"\(self.rawValue).wav\" playback completed")
        }
    }
}
