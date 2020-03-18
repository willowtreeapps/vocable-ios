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
import ARKit

class SettingsToggleCollectionViewCell: VocableCollectionViewCell {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var enabledSwitch: UISwitch!
    
    private var subscriber: AnyCancellable?
    override func awakeFromNib() {
        super.awakeFromNib()
        enabledSwitch.isUserInteractionEnabled = false
        enabledSwitch.isEnabled = AppConfig.isHeadTrackingSupported
        enabledSwitch.isOn = AppConfig.isHeadTrackingEnabled
        subscriber = AppConfig.$isHeadTrackingEnabled.sink { [weak self] isEnabled in
            self?.enabledSwitch.setOn(isEnabled, animated: true)
        }
    }
    
    override func updateContentViews() {
        super.updateContentViews()

        textLabel.textColor = .defaultTextColor
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
