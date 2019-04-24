//
//  TrackingCollectionViewCell.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/23/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class TrackingCollectionViewCell: UICollectionViewCell, TrackableWidget, CircularAnimatable {
    var hoverBorderColor: UIColor?
    var parent: TrackableWidget?
    var id: Int?
    var gazeableComponent = GazeableTrackingComponent()
    var isTrackingEnabled = true
    var isMarked = false
    
    func add(to engine: TrackingEngine) {
        if !self.isMarked {
            engine.registerView(self)
            self.isMarked = true
        }
    }
    
    lazy var animationView: UIView = {
        let view = UIView()
        self.addSubview(view)
        self.sendSubviewToBack(view)
        view.backgroundColor = .speakBoxHoverColor
        return view
    }()
    
    var animationSpeed: TimeInterval = 1.0
    
}
