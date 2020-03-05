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
    
    @IBOutlet weak var leftLabelConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.buttonImage = UIImage(systemName: "xmark.circle")!
        setConstraints()
    }
    
    func setConstraints() {
        if case .compact = self.traitCollection.verticalSizeClass {
            leftLabelConstraint.isActive = true
        }
        else if case .compact = self.traitCollection.horizontalSizeClass {
            leftLabelConstraint.isActive = true
        }
        else {
            leftLabelConstraint.isActive = false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setConstraints()
    }
    
}
