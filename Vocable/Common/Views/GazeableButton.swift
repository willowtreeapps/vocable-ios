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

    override var isEnabled: Bool {
        didSet {
            updateContentViews()
        }
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        let image = image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .bold))
        super.setImage(image, for: state)
    }
    
    func setFillColor(_ color: UIColor?, for state: UIControl.State) {

        guard let color = color else {
            setBackgroundImage(nil, for: state)
            return
        }

        let image = renderBackgroundImage(withFillColor: color, withHighlight: state.contains(.highlighted))
        setBackgroundImage(image, for: state)

        if state == .normal {
            let highlightedImage = renderBackgroundImage(withFillColor: color, withHighlight: true)
            setBackgroundImage(highlightedImage, for: .highlighted)
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

        tintColor = .defaultTextColor
        setFillColor(.defaultCellBackgroundColor, for: .normal)
        setFillColor(.cellSelectionColor, for: .selected)
        setFillColor(.cellSelectionColor, for: [.selected, .highlighted])

        layoutMargins = .zero

        let ibStates = [UIControl.State.normal, .highlighted, .selected, .disabled]
        for state in ibStates {
            if let original = image(for: state) {
                setImage(original, for: state)
            }
        }

        updateContentViews()
    }
    
    fileprivate func updateContentViews() {
        titleLabel?.alpha = CGFloat(isEnabled ? 1.0 : 0.5)
    }

    private func renderBackgroundImage(withFillColor fillColor: UIColor, withHighlight isHighlighted: Bool) -> UIImage {
        let cornerRadius: CGFloat = 8
        let borderWidth: CGFloat = 4
        let dimension = cornerRadius * 2 + 1
        let bounds = CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension))
        let image = UIGraphicsImageRenderer(bounds: bounds).image { _ in

            UIColor.collectionViewBackgroundColor.setFill()
            UIRectFill(bounds)

            let insetRect = bounds.insetBy(dx: borderWidth * 0.5, dy: borderWidth * 0.5)
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: cornerRadius - borderWidth * 0.5)
            path.lineWidth = borderWidth

            fillColor.setFill()
            path.fill()

            if isHighlighted {
                UIColor.cellBorderHighlightColor.setStroke()
                path.stroke()
            }
        }
        let capInsets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        let stretchableImage = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        return stretchableImage
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
