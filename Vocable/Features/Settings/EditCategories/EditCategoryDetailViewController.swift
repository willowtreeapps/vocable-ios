//
//  EditCategoryDetailViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
<<<<<<< HEAD
import CoreData
=======
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06

class EditCategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
<<<<<<< HEAD
    @IBOutlet weak var editButton: GazeableButton!
    
    static var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = EditCategoryDetailViewController.category?.name
        editButton.isHidden = !EditCategoryDetailViewController.category!.isUserGenerated
=======
    
    var categoryName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = categoryName
        // Do any additional setup after loading the view.
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
           if let vc = UIStoryboard(name: "EditCategories", bundle: nil).instantiateViewController(identifier: "EditCategoryKeyboardViewController") as? EditCategoryKeyboardViewController {
               vc.modalPresentationStyle = .fullScreen
<<<<<<< HEAD
            
=======
               vc.phraseIdentifier = categoryName
>>>>>>> bad08b7c2a0c84d07355e837a7d2416f4d755e06
            present(vc, animated: true)
               return
           }
    }
    
}
