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
    private var cachedTitleColors = [UIControl.State: UIColor]()
    private let defaultIBStates = [UIControl.State.normal, .highlighted, .selected, .disabled]

    var shouldShrinkWhenTouched = true {
        didSet {
            updateSelectionAppearance()
        }
    }

    private var cachedHighlightColor: UIColor?
    private(set) var isTrackingTouches: Bool = false {
        didSet {
            guard oldValue != isTrackingTouches else { return }

            if isTrackingTouches {

                if let currentFill = fillColor(for: .highlighted) ?? fillColor(for: .normal) {
                    cachedHighlightColor = currentFill
                    let newFill = currentFill.darkenedForHighlight()
                    setFillColor(newFill, for: .highlighted)
                }

            } else {
                if let cached = cachedHighlightColor {
                    setFillColor(cached, for: .highlighted)
                    cachedHighlightColor = nil
                }
            }
            updateSelectionAppearance()
            updateContentViews()
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
            updateSelectionAppearance()
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
        setFillColor(.defaultCellBackgroundColor.disabled(blending: .collectionViewBackgroundColor), for: .disabled)
        setFillColor(.defaultCellBackgroundColor, for: .normal)
        setFillColor(.cellSelectionColor, for: .selected)
        setFillColor(.cellSelectionColor, for: [.selected, .highlighted])
        setTitleColor(.collectionViewBackgroundColor, for: .selected)
        setTitleColor(.collectionViewBackgroundColor, for: [.selected, .highlighted])
        setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        titleLabel?.numberOfLines = 3
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

        let disabledState = state.union(.disabled)
        if [.normal, .selected].contains(state), cachedFillColors[disabledState] == nil {
            let disabledImage = renderBackgroundImage(withFillColor: color.disabled(blending: backgroundColor ?? .orange), withHighlight: false)
            setBackgroundImage(disabledImage, for: disabledState)
        }
    }

    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {

        defer {
            cachedTitleColors[state] = color
        }

        super.setTitleColor(color, for: state)

        let disabledState = state.union(.disabled)
        if [.normal, .selected].contains(state), cachedTitleColors[disabledState] == nil {
            let disabledColor = color?.disabled(blending: backgroundColor ?? .orange)
            super.setTitleColor(disabledColor, for: disabledState)
        }
    }

    override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        super.setAttributedTitle(title, for: state)
        setTitleColor(titleColor(for: state), for: state)
    }

    private func updateSelectionAppearance() {

        func actions() {
            let scale: CGFloat = (isHighlighted && isTrackingTouches && shouldShrinkWhenTouched) ? 0.95 : 1.0
            transform = .init(scaleX: scale, y: scale)
        }

        if UIView.inheritedAnimationDuration == 0 {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: actions,
                           completion: nil)
        } else {
            actions()
        }
    }

    private func updateBackgroundImagesForCurrentParameters() {
        for (state, color) in cachedFillColors {
            setFillColor(color, for: state)
        }
    }
    
    fileprivate func updateContentViews() {
        imageView?.tintColor = titleColor(for: state) ?? tintColor
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !(touches.first is UIHeadGaze) else { return }
        isTrackingTouches = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard !(touches.first is UIHeadGaze) else { return }
        isTrackingTouches = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard !(touches.first is UIHeadGaze) else { return }
        isTrackingTouches = false
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
