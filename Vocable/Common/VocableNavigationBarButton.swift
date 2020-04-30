//
//  VocableNavigationBarButton.swift
//  Vocable
//
//  Created by Chris Stroud on 4/29/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class VocableNavigationBarButton: GazeableButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        tintColor = .defaultTextColor
        setTitleColor(.defaultTextColor, for: .normal)
    }
}
