//
//  HotCornerView.swift
//  EyeTrackingTest
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
        static let textLabelOriginOffset = (x: CGFloat(20), y: CGFloat(20))
    }
    
    var isTrackingEnabled: Bool = true
    var expandingScale = Constants.expandingScale
    var animationSpeed = Constants.animationSpeed
    lazy var animatableComponent = ExpandingAnimatableComponent()
    
    var parent: TrackableWidget?
    var id: Int?
    var gazeableComponent = GazeableTrackingComponent()
    let location: HotCornerViewLocation
    
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.frame.height / 2.0
        }
    }
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }
    
    var text: String?
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
    
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
    
    func expandedStateLabelOrigin() -> CGPoint {
        let center = self.convert(self.center, from: self.superview)
        let coordinateSystem = self.location.coordinateSystem
        let offsetX = center.x + (coordinateSystem.x * Constants.textLabelOriginOffset.x)
        let offsetY = center.y + (coordinateSystem.y * Constants.textLabelOriginOffset.y)
        return CGPoint(x: offsetX, y: offsetY)
        
    }
    
    func convertLabelOriginPointToSuperview() -> CGPoint {
        let idleCenter = self.center
        let coordinateSystem = self.location.coordinateSystem
        let offsetX = idleCenter.x + (coordinateSystem.x * Constants.textLabelOriginOffset.x)
        let offsetY = idleCenter.y + (coordinateSystem.y * Constants.textLabelOriginOffset.y)
        return CGPoint(x: offsetX, y: offsetY)
    }
    
    func moveTextLabelToSuperview() {
        self.textLabel.removeFromSuperview()
        self.textLabel.frame.origin = self.convertLabelOriginPointToSuperview()
        self.superview?.addSubview(self.textLabel)
    }
    
    func moveTextLabelToSelf() {
        self.textLabel.removeFromSuperview()
        self.textLabel.frame.origin = self.expandedStateLabelOrigin()
        self.addSubview(self.textLabel)
    }
    
    func willExpand() {
        self.moveTextLabelToSuperview()
        self.textLabel.alpha = 0.0
        self.textLabel.text = self.text
        self.textLabel.sizeToFit()
    }
    
    func onExpand() {
        self.moveTextLabelToSelf()
        self.textLabel.alpha = 1.0
    }
    
    func willCollapse() {
        self.moveTextLabelToSuperview()
    }
    
    func onCollapse() {
        self.textLabel.alpha = 0.0
    }
}
