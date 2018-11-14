//
//  KeyView.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 10/24/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

struct KeyViewOptions {
    let topLeft: KeyViewValue?
    let topCenter: KeyViewValue?
    let topRight: KeyViewValue?
    let bottomLeft: KeyViewValue?
    let bottomCenter: KeyViewValue?
    let bottomRight: KeyViewValue?

    var allValues: [KeyViewValue] {
        return [ topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight ].compactMap{$0}
    }

    init(topLeft: KeyViewValue?,
         topCenter: KeyViewValue?,
         topRight: KeyViewValue?,
         bottomLeft: KeyViewValue?,
         bottomCenter: KeyViewValue?,
         bottomRight: KeyViewValue?) {
        self.topLeft = topLeft
        self.topCenter = topCenter
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomCenter = bottomCenter
        self.bottomRight = bottomRight
    }

}

enum KeyViewValue {
    case character(String)
    case back
    case space
    case backspace

    var display: String {
        switch self {
        case .character(let string):
            return string
        case .back:
            return ""
        case .space:
            return "⎵"
        case .backspace:
            return "bksp"
        }
    }
}

enum KeyModel {
    case options(KeyViewOptions)
    case value(KeyViewValue)
}

class KeyView: NibBackView, Gazeable {

    @IBOutlet var singleValueLabel: UILabel!

    @IBOutlet var topLeftOption: UILabel!
    @IBOutlet var topCenterOption: UILabel!
    @IBOutlet var topRightOption: UILabel!
    @IBOutlet var bottomLeftOption: UILabel!
    @IBOutlet var bottomCenterOption: UILabel!
    @IBOutlet var bottomRightOption: UILabel!

    private var optionLabels: [UILabel] {
        return [ self.topLeftOption, self.bottomLeftOption, self.topCenterOption, self.bottomCenterOption, self.topRightOption, self.bottomRightOption ]
    }

    override func didInstantiateBackingNib() {
        self.contentView.backgroundColor = .black
        self.singleValueLabel.textColor = .white
        self.optionLabels.forEach { $0.textColor = .white }
    }

    func configure(with keyModel: KeyModel) {
        switch keyModel {
        case .value(let value):
            self.singleValueLabel.isHidden = false
            self.singleValueLabel.text = value.display
            self.optionLabels.forEach { $0.isHidden = true }

        case .options(let options):
            self.singleValueLabel.isHidden = true

            self.optionLabels.forEach { $0.isHidden = false }
            self.topLeftOption.text = options.topLeft?.display
            self.topCenterOption.text = options.topCenter?.display
            self.topRightOption.text = options.topRight?.display
            self.bottomLeftOption.text = options.bottomLeft?.display
            self.bottomCenterOption.text = options.bottomCenter?.display
            self.bottomRightOption.text = options.bottomRight?.display
        }
    }

    // MARK: - TrackingView

    var onGaze: (() -> Void)? = nil

    @IBOutlet var animationView: UIView!
    @IBOutlet var animationViewWidthConstraint: NSLayoutConstraint!

    func animateGaze(withDuration duration: TimeInterval) {
        self.animationViewWidthConstraint.constant = 0
        self.layoutIfNeeded()

        self.animationView.isHidden = false
        self.animationViewWidthConstraint.constant = self.bounds.width
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }

    func cancelAnimation() {
        self.animationView.isHidden = true
        self.animationViewWidthConstraint.constant = 0
    }

}
