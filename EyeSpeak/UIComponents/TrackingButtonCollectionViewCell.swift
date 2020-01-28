//
//  TrackingButtonCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TrackingButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: TrackingButton!
    
    func setup(title: String, backgroundColor: UIColor, animationViewColor: UIColor, hoverBorderColor: UIColor) {
        
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.animationViewColor = animationViewColor
        button.hoverBorderColor = hoverBorderColor
        
        button.statelessBorderColor = .clear
        
    }

}
