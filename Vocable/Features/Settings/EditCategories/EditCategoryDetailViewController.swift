//
//  EditCategoryDetailViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import CoreData

class EditCategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: GazeableButton!
    
    static var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = EditCategoryDetailViewController.category?.name
        editButton.isHidden = !EditCategoryDetailViewController.category!.isUserGenerated
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
           if let vc = UIStoryboard(name: "EditCategories", bundle: nil).instantiateViewController(identifier: "EditCategoryKeyboardViewController") as? EditCategoryKeyboardViewController {
               vc.modalPresentationStyle = .fullScreen
            
            present(vc, animated: true)
               return
           }
    }
    
}
