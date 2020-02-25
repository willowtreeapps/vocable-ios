//
//  VocableUIControl.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class VocableUIControl: UIControl {
    
    let borderedView = BorderedView()
    
    var fillColor: UIColor = .defaultCellBackgroundColor {
        didSet {
            updateContentViews()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateContentViews()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateContentViews()
        }
    }
    
    fileprivate var defaultBackgroundColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderedView.cornerRadius = 8
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        
        updateContentViews()
        addSubview(borderedView)
    }
    
    func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
        borderedView.isOpaque = true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        self.defaultBackgroundColor = .green
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        self.defaultBackgroundColor = .blue
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        self.defaultBackgroundColor = .red
    }
    
}
