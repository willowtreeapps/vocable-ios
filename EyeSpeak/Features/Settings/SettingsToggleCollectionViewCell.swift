//
//  SettingsToggleCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Jesse Morgan on 2/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SettingsToggleCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var enabledSwitch: UISwitch!
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        enabledSwitch.isUserInteractionEnabled = false
        _ = AppConfig.headTrackingValueSubject.sink { (isHeadTrackingEnabled) in
            self.enabledSwitch.setOn(isHeadTrackingEnabled, animated: true)
        }.store(in: &disposables)
    }
    
    override func updateContentViews() {
        super.updateContentViews()

        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = .collectionViewBackgroundColor
        textLabel.isOpaque = true
        textLabel.font = UIFont.systemFont(ofSize: 22)
        
        borderedView.fillColor = .collectionViewBackgroundColor
    }

    func setup(title: String) {
        textLabel.text = title
    }
    
    func setup(with image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSAttributedString(attachment: systemImageAttachment)
        
        textLabel.attributedText = attributedString
    }

}
