//
//  VocableUIControl.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GazeableButton: UIButton {
    
    fileprivate var gazeBeganDate: Date?
    
    let backgroundView = BorderedView()
    private var buttonImageView = UIImageView()
    private var buttonImageWidthConstraint: NSLayoutConstraint?
    private var buttonImageHeightConstraint: NSLayoutConstraint?
    
    override var isEnabled: Bool {
        didSet {
            let alpha = CGFloat(isEnabled ? 1.0 : 0.5)
            backgroundView.alpha = alpha
        }
    }

    @IBInspectable
    var buttonImage: UIImage? {
        didSet {
            buttonImage = buttonImage?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .bold))
            buttonImageView.image = buttonImage
            updateContentViews()
        }
    }
    @IBInspectable
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateContentViews()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateContentViews()
    }
    
    private func commonInit() {

        backgroundView.isUserInteractionEnabled = false

        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        buttonImageView = UIImageView(image: buttonImage)
        buttonImageView.contentMode = .scaleAspectFit

        addSubview(buttonImageView)
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false

        let buttonSize = buttonImageViewSizeForCurrentTraitCollection()
        let widthConstraint = buttonImageView.widthAnchor.constraint(equalToConstant: buttonSize.width)
        let heightConstraint = buttonImageView.heightAnchor.constraint(equalToConstant: buttonSize.height)
        NSLayoutConstraint.activate([
            buttonImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthConstraint,
            heightConstraint
        ])
        buttonImageWidthConstraint = widthConstraint
        buttonImageHeightConstraint = heightConstraint
    }

    private func buttonImageViewSizeForCurrentTraitCollection() -> CGSize {
        if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
            return CGSize(width: 42, height: 42)
        }
        return CGSize(width: 34, height: 34)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let buttonSize = buttonImageViewSizeForCurrentTraitCollection()
        buttonImageWidthConstraint?.constant = buttonSize.width
        buttonImageHeightConstraint?.constant = buttonSize.height
        updateContentViews()
    }
    
    fileprivate func updateContentViews() {
        backgroundView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        backgroundView.fillColor = isSelected ? selectionFillColor : fillColor
        backgroundView.borderColor = .cellBorderHighlightColor
        backgroundView.cornerRadius = 8
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
        
        let timeElapsed = Date().timeIntervalSince(beganDate)
        if timeElapsed >= AppConfig.selectionHoldDuration {
            isSelected = true
            sendActions(for: .primaryActionTriggered)
            gazeBeganDate = nil
            (self.window as? HeadGazeWindow)?.animateCursorSelection()
        }
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeEnded(gaze, with: event)
        
        gazeBeganDate = nil
        isSelected = false
        isHighlighted = false
    }

    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        super.gazeCancelled(gaze, with: event)
        isHighlighted = false
        isSelected = false
        gazeBeganDate = .distantFuture
    }
    
}

class GazeableSegmentedButton: GazeableButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSelected {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if !isSelected {
            isHighlighted = true
        }
        gazeBeganDate = Date()
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if !isSelected {
            gazeBeganDate = nil
            isSelected = false
        }
        isHighlighted = false
    }
    
}
