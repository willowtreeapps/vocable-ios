//
//  UIViewController+Segues.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension UIViewController {
    func perform(segue: Segue, sender: Any?) {
        self.performSegue(withIdentifier: segue.rawValue, sender: sender)
    }
}
