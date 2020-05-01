//
//  RootViewController.swift
//  Vocable AAC
//
//  Created by Steve Foster on 4/23/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable class RootViewController: VocableViewController {

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var keyboardButton: GazeableButton!
    @IBOutlet weak var settingsButton: GazeableButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

}
