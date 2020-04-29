//
//  SettingsViewController.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    @IBOutlet private weak var dismissButton: GazeableButton!
    @IBOutlet private weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.buttonImage = UIImage(systemName: "xmark.circle")!
        titleLabel.text = NSLocalizedString("settings.header.title",
                                            comment: "Settings screen header title")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (self.view.window as? HeadGazeWindow)?.cancelActiveGazeTarget()
    }

    @IBAction func dismissSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
