//
//  EditCategoryDetailViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class EditCategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var categoryName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = categoryName
        // Do any additional setup after loading the view.
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
           if let vc = UIStoryboard(name: "EditCategories", bundle: nil).instantiateViewController(identifier: "EditCategoryKeyboardViewController") as? EditCategoryKeyboardViewController {
               vc.modalPresentationStyle = .fullScreen
               vc.phraseIdentifier = categoryName
            present(vc, animated: true)
               return
           }
    }
    
}
