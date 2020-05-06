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
    private(set) var isTrackingTouches: Bool = false {
        didSet {
            updateSelectionAppearance()
            updateContentViews()
        }
    }

    var fillColor: UIColor = .defaultCellBackgroundColor {
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

    var isEnabled: Bool = true {
        didSet {
            updateContentViews()
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
        updateContentViews()
        backgroundView = borderedView
    }
    
    func updateContentViews() {

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

    private func updateSelectionAppearance() {

        func actions() {
            let scale: CGFloat = (isHighlighted && isTrackingTouches) ? 0.97 : 1.0
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
