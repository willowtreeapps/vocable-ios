//
//  PresetsViewController.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class PresetsViewController: HotCornersViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.upperLeftHotCorner.onGaze = { _ in
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.trackingEngine.disable()
    }
}
