//
//  SettingsToggleCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 2/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SettingsCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func updateContentViews() {
        super.updateContentViews()

        textLabel.textColor = .defaultTextColor
        textLabel.font = UIFont.systemFont(ofSize: 22)
    }

    func setup(title: String, image: UIImage?) {
        guard let image = image else {
            return
        }
        
        textLabel.text = title
        imageView.image = image
    }

}
