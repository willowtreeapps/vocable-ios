//
//  PhraseSavedView.swift
//  Vocable
//
//  Created by Chris Stroud on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable
class PhraseSavedView: BorderedView {
    
    
    @IBOutlet weak var alertLabel: UILabel!
    
    override var bounds: CGRect {
        didSet {
            cornerRadius = bounds.height / 2
        }
    }

    override var frame: CGRect {
        didSet {
            cornerRadius = frame.height / 2
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setAlertText(text: String) {
        alertLabel.text = text
    }
}
