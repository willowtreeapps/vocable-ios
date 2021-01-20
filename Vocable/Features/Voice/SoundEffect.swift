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
        var data = [SoundEffect: Data]()
        static var shared = Storage()
    }

    case listening = "Listening"
    case paused = "Paused"

    var soundData: Data? {

        if let contents = Storage.shared.data[self] {
            return contents
        }

        guard let url = Bundle.main.url(forResource: rawValue, withExtension: "wav"),
              let data = try? Data(contentsOf: url) else {
            assertionFailure("File not found for name \"\(rawValue)\" of type .wav")
            return nil
        }
        Storage.shared.data[self] = data
        return data
    }
}
