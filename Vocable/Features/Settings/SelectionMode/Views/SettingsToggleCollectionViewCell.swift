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

    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var enabledSwitch: UISwitch!

    private var valueCancellable: AnyCancellable?

    override func awakeFromNib() {
        super.awakeFromNib()

        enabledSwitch.isUserInteractionEnabled = false
    }

    func setup(title: String, value: CurrentValueSubject<Bool, Never>) {
        textLabel.text = title
        enabledSwitch.isEnabled = value.value
        enabledSwitch.isOn = value.value
        valueCancellable = value.dropFirst().sink { [weak self] isEnabled in
            self?.enabledSwitch.setOn(isEnabled, animated: true)
            self?.enabledSwitch.isEnabled = isEnabled
        }
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
