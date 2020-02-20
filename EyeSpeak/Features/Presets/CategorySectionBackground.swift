//
//  CategorySectionBackground.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/5/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//
import UIKit

class CategorySectionBackground: UICollectionReusableView {

    private let borderedView = BorderedView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.addSubview(borderedView)

        borderedView.translatesAutoresizingMaskIntoConstraints = false
        borderedView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        borderedView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        borderedView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        borderedView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        borderedView.cornerRadius = 16
        borderedView.fillColor = .categoryBackgroundColor
        self.backgroundColor = .collectionViewBackgroundColor
    }
}
