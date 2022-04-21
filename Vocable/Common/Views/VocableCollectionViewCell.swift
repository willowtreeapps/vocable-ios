//
//  VocableCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

/// A data item presented with Vocable styling
class VocableCollectionViewCell: UICollectionViewCell {
    
    let borderedView = BorderedView()

    private var needsUpdateContent = false

    func setNeedsUpdateContent() {
        needsUpdateContent = true
        setNeedsLayout()
    }

    private(set) var isTrackingTouches: Bool = false {
        didSet {
            guard oldValue != isTrackingTouches else { return }
            updateSelectionAppearance()
            setNeedsUpdateContent()
        }
    }

    var fillColor: UIColor = .defaultCellBackgroundColor {
        didSet {
            guard oldValue != fillColor else { return }
            setNeedsUpdateContent()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            updateSelectionAppearance()
            setNeedsUpdateContent()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            updateSelectionAppearance()
            setNeedsUpdateContent()
        }
    }

    var isEnabled: Bool = true {
        didSet {
            guard oldValue != isEnabled else { return }
            setNeedsUpdateContent()
        }
    }
    
    fileprivate var defaultBackgroundColor: UIColor?
    
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
        commonInit()
    }
    
    private func commonInit() {
        setNeedsUpdateContent()
        backgroundView = borderedView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if needsUpdateContent {
            updateContent()
            needsUpdateContent = false
        }
    }
    
    func updateContent() {

        let fillColor: UIColor = {
            var result: UIColor
            if isSelected {
                result = .cellSelectionColor
            } else if !isEnabled {
                result = self.fillColor.disabled(blending: .collectionViewBackgroundColor)
            } else {
                result = self.fillColor
            }

            if isHighlighted && isTrackingTouches {
                result = result.darkenedForHighlight()
            }
            return result
        }()

        insetsLayoutMarginsFromSafeArea = false

        borderedView.cornerRadius = 8
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = fillColor
        borderedView.isOpaque = true
    }

    private var _isScaledDown = false

    private func updateSelectionAppearance() {

        let shouldScaleDown = isHighlighted && isTrackingTouches

        guard shouldScaleDown != _isScaledDown else {
            return
        }
        _isScaledDown = shouldScaleDown

        func actions() {
            let scale: CGFloat = shouldScaleDown ? 0.97 : 1.0
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
