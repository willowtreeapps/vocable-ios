//
//  PhraseSavedView.swift
//  Vocable
//
//  Created by Chris Stroud on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable
class ToastView: BorderedView {
    
    @IBOutlet private var titleLabel: UILabel!
    
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
    
    var text: String = "" {
        didSet {
            titleLabel?.text = text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)
    }
}
