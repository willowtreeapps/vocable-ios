//
//  SettingsViewController.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/6/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SettingsViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .collectionViewBackgroundColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = .collectionViewBackgroundColor
        let textAttr = [NSAttributedString.Key.foregroundColor: UIColor.defaultTextColor]
        self.navigationController?.navigationBar.titleTextAttributes = textAttr
    }
    
    

}
