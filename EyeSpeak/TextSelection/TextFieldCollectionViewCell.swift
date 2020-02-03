//
//  TextFieldCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 1/28/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textField: TrackingTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textField.textContainerInset = UIEdgeInsets(value: 4.0)
        textField.backgroundColor = .textBoxFill
        textField.statelessBorderColor = UIColor.textBoxBorder
        textField.animationViewColor = .textBoxBloom
        textField.hoverBorderColor = .textBoxBorderHover
        
        animateCursor()
    }
    
    private func animateCursor() {
        textField.runCursor()
        textField.changeCursorPoint()
    }
}
