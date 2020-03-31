//
//  EditCategoryRemoveCollectionViewCell.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/31/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class EditCategoryRemoveCollectionViewCell: VocableCollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.text = NSLocalizedString("Remove Category", comment: "Remove category label.")

    }

}
