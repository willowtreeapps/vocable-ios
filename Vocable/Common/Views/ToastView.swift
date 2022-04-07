//
//  PhraseSavedView.swift
//  Vocable
//
//  Created by Chris Stroud on 3/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

@IBDesignable
class ToastView: UIView {
    
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    var text: String = "" {
        didSet {
            titleLabel?.text = text
        }
    }

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = 30
        layer.masksToBounds = true
    }
}
