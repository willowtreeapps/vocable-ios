//
//  TimingSensitivityViewController.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class TimingSensitivityViewController: UIViewController {
    
    @IBOutlet var backButton: GazeableButton!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
     }
    
}
