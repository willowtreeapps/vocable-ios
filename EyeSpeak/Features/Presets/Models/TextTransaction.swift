//
//  TextTransaction.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct TextTransaction {
    let attrText: NSAttributedString
    
    // To keep track of when to delete the last word or the full word (after selecting a text suggestion) when pressing backspace
    // on the keyboard.
    enum changeType {
        case lastLetter
        case fullWord
    }
    
}
