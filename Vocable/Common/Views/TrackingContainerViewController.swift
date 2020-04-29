//
//  TrackingContainerViewController.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

final class TrackingContainerViewController: UIViewController {

    private var contentViewController: UIViewController!
    private var trackingViewController: UIHeadGazeViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContentViewControllerSegue" {
            self.contentViewController = segue.destination
        }
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }
}
