//
//  EditSayingsViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/11/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class EditSayingsViewController: UIViewController {

    @IBOutlet private var addButton: GazeableButton!
    @IBOutlet private var backButton: GazeableButton!
    
    
    @IBAction func backToSettings(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
