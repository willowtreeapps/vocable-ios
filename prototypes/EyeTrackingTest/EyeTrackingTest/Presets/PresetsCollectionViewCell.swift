//
//  PresetsCollectionViewCell.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class PresetsCollectionViewCell: TrackingCollectionViewCell {
    @IBOutlet weak var presetsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.presetsLabel.textColor = .mainTextColor
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = UIColor.mainWidgetBorderColor.cgColor
        self.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        self.presetsLabel.textComponentText = ""
        self.onGaze = nil
    }
    
    func configure(with preset: PresetModel) {
        self.presetsLabel.textComponentText = preset.value
    }
    
}
