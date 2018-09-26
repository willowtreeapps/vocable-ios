//
//  ScreenTrackingViewControllerDelegate.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/11/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit

protocol ScreenTrackingViewControllerDelegate: AnyObject {
    func didUpdateTrackedPosition(_ trackedPositionOnScreen: CGPoint?, for screenTrackingViewController: ScreenTrackingViewController)
}
