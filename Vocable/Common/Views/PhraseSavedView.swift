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
}
