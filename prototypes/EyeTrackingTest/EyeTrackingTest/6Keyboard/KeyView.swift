//
//  KeyView.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 10/24/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

class KeyView: NibBackView {

    @IBOutlet var topLeftOption: UILabel!
    @IBOutlet var bottomLeftOption: UILabel!
    @IBOutlet var topCenterOption: UILabel!
    @IBOutlet var bottomCenterOption: UILabel!
    @IBOutlet var topRightOption: UILabel!
    @IBOutlet var bottomRightOption: UILabel!

    override func didInstantiateBackingNib() {
            
    }

}
