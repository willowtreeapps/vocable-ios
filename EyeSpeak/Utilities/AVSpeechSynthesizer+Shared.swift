//
//  AVSpeechSynthesizer+Shared.swift
//  EyeSpeak
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
    static var shared: AVSpeechSynthesizer {
        return Storage.shared
    }
}
