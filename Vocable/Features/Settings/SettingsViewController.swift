//
//  SettingsViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var dismissButton: GazeableButton!

    @IBOutlet var titleLabel: UILabel!

    @IBAction func dismissSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.buttonImage = UIImage(systemName: "xmark.circle")!
        titleLabel.text = NSLocalizedString("Settings", comment: "Title: Settings")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }
}
