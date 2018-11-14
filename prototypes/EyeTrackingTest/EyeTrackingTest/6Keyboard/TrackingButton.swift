//
//  TrackingButton.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/6/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit


class TrackingButton: UIButton, Gazeable {
    
    func animateGaze(withDuration: TimeInterval) {

    }

    func cancelAnimation() {

    }


    var onGaze: (() -> Void)?

}
