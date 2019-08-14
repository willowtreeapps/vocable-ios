//
//  HasTextComponent.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/24/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

protocol HasTextComponent: class {
    var textComponentText: String? { get set }
    var textComponentTextColor: UIColor? { get set }
}

extension UILabel: HasTextComponent {
    var textComponentText: String? {
        get {
            return self.text
        }
        set {
            self.text = newValue
        }
    }
    
    var textComponentTextColor: UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
}

extension UIButton: HasTextComponent {
    var textComponentText: String? {
        get {
            return self.currentTitle
        }
        set {
            self.setTitle(newValue, for: .normal)
        }
    }
    
    var textComponentTextColor: UIColor? {
        get {
            return self.titleColor(for: .normal)
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }
}

extension UITextView: HasTextComponent {
    var textComponentText: String? {
        get {
            return self.text
        }
        set {
            self.text = newValue ?? ""
        }
    }
    
    var textComponentTextColor: UIColor? {
        get {
            return self.textColor
        }
        set {
            self.textColor = newValue
        }
    }
}
