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
    
    private var gazeBeganDate: Date?
    
    let backgroundView = BorderedView()
    
    var buttonImage: UIImage = UIImage() {
        didSet {
            sharedInit()
        }
    }
    
    var fillColor: UIColor = .defaultCellBackgroundColor {
        didSet {
            updateContentViews()
        }
    }
    
    var selectionFillColor: UIColor = .cellSelectionColor {
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
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func sharedInit() {
        backgroundView.cornerRadius = 8
        backgroundView.borderColor = .cellBorderHighlightColor
        backgroundView.isUserInteractionEnabled = false

        updateContentViews()
        let image = buttonImage.withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .bold))
        let imageView = UIImageView(image: image)
        backgroundView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
        
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    func updateContentViews() {
        backgroundView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        backgroundView.fillColor = isSelected ? selectionFillColor : fillColor
        backgroundView.isOpaque = true
    }
    
    override var canReceiveGaze: Bool {
        return true
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeBegan(gaze, with: event)
        
        isHighlighted = true
        gazeBeganDate = Date()
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeMoved(gaze, with: event)
        
        guard let beganDate = gazeBeganDate else {
            return
        }
        
        // TODO: Check for performance issues calling Date().timeIntervalSince here
        let timeElapsed = Date().timeIntervalSince(beganDate)
        if timeElapsed >= gaze.selectionHoldDuration {
            isSelected = true
            sendActions(for: .primaryActionTriggered)
            gazeBeganDate = nil
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeEnded(gaze, with: event)
        
        gazeBeganDate = nil
        isSelected = false
        isHighlighted = false
    }
    
}
