//
//  EditSayingsViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class EditSayingsViewController: UIViewController {

    @IBOutlet var addButton: GazeableButton!
    @IBOutlet var backButton: GazeableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backToSettings(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
