//
//  VocableUIControl.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class GazeableButton: UIButton {
    
    var beginDate = Date()
    
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
        borderedView.isUserInteractionEnabled = false
        borderedView.fillColor = .clear

        updateContentViews()
        addSubview(borderedView)
        borderedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderedView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            borderedView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            borderedView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            borderedView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    func updateContentViews() {
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
        borderedView.isOpaque = true
    }
    
    override var canReceiveGaze: Bool {
        return true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isHighlighted = true
        beginDate = Date()
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        let timeElapsed = Date().timeIntervalSince(beginDate)
        if timeElapsed >= gaze.selectionHoldDuration {
            isSelected = true
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isSelected = false
        isHighlighted = false
    }
    
}
