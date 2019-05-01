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
    
    var smallDisplay: String {
        switch self {
        case .character(let string):
            return string
        case .back:
            return ""
        case .space:
            return "⎵"
        }
    }

    var largeDisplay: String {
        switch self {
        case .character(let string):
            return string
        case .back:
            return "\u{2190} back"
        case .space:
            return "⎵"
        }
    }
    
    var largeDisplayBackgroundColor: UIColor {
        switch self {
        case .back:
            return .backButtonBackgroundColor
        default:
            return KeyView.Constants.normalBackgroundColor
        }
    }
    
    var largeDisplayTextFont: UIFont {
        switch self {
        case .back:
            return UIFont.systemFont(ofSize: 40.0, weight: .semibold)
        default:
            return UIFont.systemFont(ofSize: 64.0, weight: .semibold)
        }
    }
}

enum KeyModel {
    case options(KeyViewOptions)
    case value(KeyViewValue)
}

class KeyView: NibBackView, TrackableWidget, CircularAnimatable {
    var hoverBorderColor: UIColor?
    var isTrackingEnabled: Bool = true
    var animationSpeed: TimeInterval = 1.0
    
    var id: Int?
    var parent: TrackableWidget?
    var gazeableComponent = GazeableTrackingComponent()
    
    lazy var animationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.animatingColor
        self.addSubview(view)
        return view
    }()
    
    struct Constants {
        static let normalBackgroundColor = UIColor.appBackgroundColor
    }
    
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
        self.optionLabels.forEach { label in
            label.adjustsFontSizeToFitWidth = true
        }
        self.singleValueLabel.adjustsFontSizeToFitWidth = true
        self.contentView.backgroundColor = Constants.normalBackgroundColor
        self.singleValueLabel.textColor = .mainTextColor
        self.optionLabels.forEach { $0.textColor = .mainTextColor }
    }

    func configure(with keyModel: KeyModel) {
        switch keyModel {
        case .value(let value):
            self.singleValueLabel.isHidden = false
            self.singleValueLabel.textComponentText = value.largeDisplay
            self.contentView.backgroundColor = value.largeDisplayBackgroundColor
            self.singleValueLabel.font = value.largeDisplayTextFont
            self.optionLabels.forEach { $0.isHidden = true }

        case .options(let options):
            self.singleValueLabel.isHidden = true
            self.contentView.backgroundColor = Constants.normalBackgroundColor
            self.optionLabels.forEach { $0.isHidden = false }
            self.topLeftOption.textComponentText = options.topLeft?.smallDisplay
            self.topCenterOption.textComponentText = options.topCenter?.smallDisplay
            self.topRightOption.textComponentText = options.topRight?.smallDisplay
            self.bottomLeftOption.textComponentText = options.bottomLeft?.smallDisplay
            self.bottomCenterOption.textComponentText = options.bottomCenter?.smallDisplay
            self.bottomRightOption.textComponentText = options.bottomRight?.smallDisplay
        }
    }

    // MARK: - TrackingView
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }
}
