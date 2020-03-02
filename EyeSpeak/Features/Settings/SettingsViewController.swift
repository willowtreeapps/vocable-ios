//
//  SettingsViewController.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var dismissButton: GazeableButton!

    @IBAction func dismissSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var warningView: UIView!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidAcquireGaze(_:)), name: .applicationDidAcquireGaze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidLoseGaze(_:)), name: .applicationDidLoseGaze, object: nil)
        if !UIApplication.shared.isGazeTrackingActive {
            warningView.alpha = 1.0
        }
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
