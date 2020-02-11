//
//  TrackingContainerViewController.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class TrackingContainerViewController: UIViewController {

    @IBOutlet private var cursorView: UIVirtualCursorView!
    
    private var contentViewController: UIViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContentViewControllerSegue" {
            self.contentViewController = segue.destination
        }
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }
}
