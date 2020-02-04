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

    private var defaultBackgroundColor: UIColor?

    override var isHighlighted: Bool {
        didSet {
            self.backgroundView?.backgroundColor = currentBackgroundColor
        }
    }

    override var isSelected: Bool {
        didSet {
            self.backgroundView?.backgroundColor = currentBackgroundColor
        }
    }

    private var currentBackgroundColor: UIColor? {
        if isSelected {
            return .blue
        }
        if isHighlighted {
            return .green
        }
        return defaultBackgroundColor
    }

    func setup(title: String, titleColor: UIColor, textStyle: UIFont.TextStyle, backgroundColor: UIColor, animationViewColor: UIColor, borderColor: UIColor) {

        // adjust button text styling
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.font = .preferredFont(forTextStyle: textStyle)
            
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center

        button.backgroundColor = .clear
        button.animationViewColor = animationViewColor
        button.isUserInteractionEnabled = false
        
        backgroundView?.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 6.0
        contentView.layer.borderWidth = 4.0
        contentView.layer.borderColor = borderColor.cgColor
        contentView.layer.masksToBounds = true

        let bg = UIView(frame: .zero)
        bg.backgroundColor = backgroundColor
        self.backgroundView = bg

        defaultBackgroundColor = backgroundColor
    }

}
