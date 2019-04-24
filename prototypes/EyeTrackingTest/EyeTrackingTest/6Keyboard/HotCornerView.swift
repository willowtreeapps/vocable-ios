//
//  HotCornerView.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/18/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

enum HotCornerViewState {
    case idle
    case expanding
    case collapsing
    case expanded
}

class HotCornerView: TrackingView, ExpandingAnimatable {
    var isTrackingEnabled: Bool = true
    var expandingScale: CGFloat = 10.0
    var animationSpeed: TimeInterval = 1.0
    var animatableState: ExpandingAnimatableState = .idle
    lazy var animatableComponent = ExpandingAnimatableComponent(isTrackingEnabled: self.isTrackingEnabled)
    override var frame: CGRect {
        didSet {
            self.layer.cornerRadius = self.frame.height / 2.0
        }
    }
    
    var parent: TrackableWidget?
    var id: Int?
    var gazeableComponent = GazeableTrackingComponent()
    
    func add(to engine: TrackingEngine) {
        engine.registerView(self)
    }
    
    init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.hotCornerColor
        self.clipsToBounds = true
        self.layoutIfNeeded()
    }
}
