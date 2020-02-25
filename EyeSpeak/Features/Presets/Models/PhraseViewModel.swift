//
//  PhraseViewModel.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct PhraseViewModel: Hashable {
    let identifier: String
    let utterance: String
    let creationDate: Date
    
    init?(_ phrase: Phrase?) {
        guard let identifier = phrase?.identifier,
            let utterance = phrase?.utterance,
            let creationDate = phrase?.creationDate else {
                return nil
        }
        
        self.identifier = identifier
        self.utterance = utterance
        self.creationDate = creationDate
    }
}
