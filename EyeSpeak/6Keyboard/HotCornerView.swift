//
//  HotCornerView.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/18/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

enum HotCornerViewLocation {
    case upperLeft
    case upperRight
    case lowerLeft
    case lowerRight
    case unknown
    
    var isUpper: Bool {
        return self == .upperLeft || self == .upperRight
    }
    
    var isLower: Bool {
        return self == .lowerLeft || self == .lowerRight
    }
    
    var isLeft: Bool {
        return self == .upperLeft || self == .lowerLeft
    }
    
    var isRight: Bool {
        return self == .upperRight || self == .lowerRight
    }
    
    var coordinateSystem: (x: CGFloat, y: CGFloat) {
        switch self {
        case .upperLeft: return (1.0, 1.0)
        case .upperRight: return (-1.0, 1.0)
        case .lowerLeft: return (1.0, -1.0)
        case .lowerRight: return (-1.0, -1.0)
        case .unknown: return (0.0, 0.0)
        }
    }
}

enum HotCornerViewState {
    case idle
    case expanding
    case collapsing
    case expanded
    
    var isMoving: Bool {
        switch self {
        case .idle:
            return false
        default:
            return true
        }
    }
}

class HotCornerView: TrackingView, ExpandingAnimatable {
    struct Constants {
        static let expandingScale = CGFloat(10.0)
        static let animationSpeed = TimeInterval(1.0)
        static let textLabelOriginOffset = (x: CGFloat(30), y: CGFloat(30))
    }
    
    var isTrackingEnabled: Bool = true
    var expandingScale = Constants.expandingScale
    var animationSpeed = Constants.animationSpeed
    lazy var animatableComponent = ExpandingAnimatableComponent()
    
    var parent: TrackableWidget?
    var id: Int?
    var gazeableComponent = GazeableTrackingComponent()
    let location: HotCornerViewLocation
    
    var animatingView: UIView {
        return self
    }
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.frame.height / 2.0
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.layer.cornerRadius = self.bounds.height / 2.0
        }
    }
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }
    
    var text: String?
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.alpha = 0.0
        self.addSubview(label)
        return label
    }()
    
    var textOffsetOrigin: CGPoint {
        var newXOffset = Constants.textLabelOriginOffset.x * self.location.coordinateSystem.x
        var newYOffset = Constants.textLabelOriginOffset.y * self.location.coordinateSystem.y
        if self.location.isLower {
            newYOffset -= self.textLabel.frame.height
        }
        if self.location.isRight {
            newXOffset -= self.textLabel.frame.width
        }
        return CGPoint(x: newXOffset, y: newYOffset)
    }
    
    init(location: HotCornerViewLocation) {
        self.location = location
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.location = .unknown
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .hotCornerColor
        self.clipsToBounds = true
        self.layoutIfNeeded()
    }
    
    func willExpand() {
        self.textLabel.text = self.text
        self.textLabel.alpha = 1.0
        self.textLabel.frame = CGRect(origin: self.textOffsetOrigin, size: self.frame.size)
        self.textLabel.sizeToFit()
        self.textLabel.setNeedsLayout()
    }
    func onExpand() {}
    func willCollapse() {}
    func onCollapse() {}
}
