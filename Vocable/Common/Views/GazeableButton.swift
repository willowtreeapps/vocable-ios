//
//  VocableUIControl.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

extension UIControl.State: Hashable {

}

@IBDesignable
class GazeableButton: UIButton {

    fileprivate var gazeBeganDate: Date?
    private var cachedFillColors = [UIControl.State: UIColor]()
    private let defaultIBStates = [UIControl.State.normal, .highlighted, .selected, .disabled]

    @available(*, deprecated, message: "Use setImage(forState:) instead")
    @IBInspectable var buttonImage: UIImage? {
        get {
            return image(for: .normal)
        }
        set {
            print("Warning: using deprecated `buttonImage` property on GazeableButton")
            for state in defaultIBStates {
                setImage(newValue, for: state)
            }
        }
    }

    @available(*, deprecated, message: "Use setFillColor(forState:) instead")
    @IBInspectable var fillColor: UIColor? {
        get {
            return fillColor(for: .normal)
        }
        set {
            print("Warning: using deprecated `fillColor` property on GazeableButton")
            for state in defaultIBStates {
                setFillColor(newValue, for: state)
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 8 {
        didSet {
            guard oldValue != cornerRadius else { return }
            updateBackgroundImagesForCurrentParameters()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 4 {
        didSet {
            guard oldValue != borderWidth else { return }
            updateBackgroundImagesForCurrentParameters()
        }
    }

    var roundedCorners: UIRectCorner = .allCorners {
        didSet {
            guard oldValue != roundedCorners else { return }
            updateBackgroundImagesForCurrentParameters()
        }
    }

    override var isEnabled: Bool {
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

    override var backgroundColor: UIColor? {
        didSet {
            guard oldValue != backgroundColor else { return }
            updateBackgroundImagesForCurrentParameters()
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
    
    private func commonInit() {
        setDefaultAppearance()
        updateContentViews()
    }

    private func setDefaultAppearance() {
        tintColor = .defaultTextColor
        setFillColor(.defaultCellBackgroundColor, for: .normal)
        setFillColor(.cellSelectionColor, for: .selected)
        setFillColor(.cellSelectionColor, for: [.selected, .highlighted])
        contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        layoutMargins = .zero
        for state in defaultIBStates {
            if let original = image(for: state) {
                setImage(original, for: state)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateContentViews()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setDefaultAppearance()
        updateContentViews()
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .bold)
        let image = image?.withConfiguration(symbolConfiguration)
        super.setImage(image, for: state)
    }

    func fillColor(for state: UIControl.State) -> UIColor? {
        return cachedFillColors[state]
    }

    func setFillColor(_ color: UIColor?, for state: UIControl.State) {

        defer {
            cachedFillColors[state] = color
        }

        guard let color = color else {
            setBackgroundImage(nil, for: state)
            return
        }

        let image = renderBackgroundImage(withFillColor: color, withHighlight: state.contains(.highlighted) && !state.contains(.selected))
        setBackgroundImage(image, for: state)

        if state == .normal {
            let highlightedImage = renderBackgroundImage(withFillColor: color, withHighlight: true)
            setBackgroundImage(highlightedImage, for: .highlighted)
        }
    }

    private func updateBackgroundImagesForCurrentParameters() {
        for (state, color) in cachedFillColors {
            setFillColor(color, for: state)
        }
    }
    
    fileprivate func updateContentViews() {
        titleLabel?.alpha = CGFloat(isEnabled ? 1.0 : 0.5)
        adjustsImageWhenHighlighted = false
        showsTouchWhenHighlighted = false
        imageView?.contentMode = .scaleAspectFit
    }

    private func renderBackgroundImage(withFillColor fillColor: UIColor, withHighlight isHighlighted: Bool) -> UIImage {
        let dimension = cornerRadius * 2 + 1
        let bounds = CGRect(origin: .zero, size: CGSize(width: dimension, height: dimension))
        let image = UIGraphicsImageRenderer(bounds: bounds).image { _ in

            let backgroundFillColor: UIColor = backgroundColor ?? .collectionViewBackgroundColor
            backgroundFillColor.setFill()
            UIRectFill(bounds)

            let insetRect = bounds.insetBy(dx: borderWidth * 0.5, dy: borderWidth * 0.5)
            let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
            let path = UIBezierPath(roundedRect: insetRect, byRoundingCorners: roundedCorners, cornerRadii: cornerSize)
            path.lineWidth = borderWidth

            fillColor.setFill()
            path.fill()

            let strokeColor = isHighlighted ? UIColor.cellBorderHighlightColor : fillColor
            strokeColor.setStroke()
            path.stroke()
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
