//
//  SensitivityCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class SensitivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var lowButton: GazeableSegmentedButton!
    @IBOutlet var mediumButton: GazeableSegmentedButton!
    @IBOutlet var highButton: GazeableSegmentedButton!
    
    private var disposables = Set<AnyCancellable>()
    
    // have sink in awakeFromNib to update fill color based on currently selected sensitivity
    override func awakeFromNib() {
        super.awakeFromNib()
        
        AppConfig.$sensitivity.sink { (sensitivity) in
            UIView.performWithoutAnimation {
                self.lowButton.isSelected = false
                self.mediumButton.isSelected = false
                self.highButton.isSelected = false
                
                if case .low = sensitivity {
                    self.lowButton.isSelected = true
                } else if case .medium = sensitivity {
                    self.mediumButton.isSelected = true
                } else if case .high = sensitivity {
                    self.highButton.isSelected = true
                }
            }
        }.store(in: &disposables)
    }
    
    // have IBAction functions here to update AppConfig user defaults
    @IBAction func handleLowSensitivity(_ sender: Any) {
        AppConfig.sensitivity = .low
    }
    
    @IBAction func handleMediumSensitivity(_ sender: Any) {
        AppConfig.sensitivity = .medium
    }
    
    @IBAction func handleHighSensitivity(_ sender: Any) {
        AppConfig.sensitivity = .high
    }
}
