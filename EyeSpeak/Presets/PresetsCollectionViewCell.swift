//
//  PresetsCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 4/19/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

class PresetsCollectionViewCell: TrackingCollectionViewCell {
    struct Constants {
        static let borderWidth = CGFloat(3.0)
        static let borderRadius = CGFloat(5.0)
    }
    @IBOutlet weak var presetsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.presetsLabel.textColor = .mainTextColor
        self.hoverBorderColor = .textBoxBorderHover
        self.animationView.backgroundColor = .textBoxBloom
        self.statelessBorderColor = .textBoxBorder
        self.backgroundColor = .textBoxFill
        self.layer.borderWidth = Constants.borderWidth
        self.layer.cornerRadius = Constants.borderRadius
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
