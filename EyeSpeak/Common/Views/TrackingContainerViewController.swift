//
//  TrackingContainerViewController.swift
//  EyeSpeak
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class TrackingContainerViewController: UIViewController {

    @IBOutlet weak var warningView: UIView!
    @IBOutlet private var cursorView: UIVirtualCursorView!
    
    private var contentViewController: UIViewController!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContentViewControllerSegue" {
            self.contentViewController = segue.destination
        }
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }
    
    @objc private func applicationDidAcquireGaze(_ sender: Any?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.warningView.alpha = 0.0
        })
    }

    @objc private func applicationDidLoseGaze(_ sender: Any?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.warningView.alpha = 1.0
        })
    }
}
