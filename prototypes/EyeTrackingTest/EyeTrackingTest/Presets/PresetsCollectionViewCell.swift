//
//  PresetsCollectionViewCell.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class PresetsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var presetsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.mainPageBorderColor.cgColor
        self.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        self.presetsLabel.text = ""
    }
    
    func configure(with preset: String) {
        self.presetsLabel.text = preset
    }
    
}
