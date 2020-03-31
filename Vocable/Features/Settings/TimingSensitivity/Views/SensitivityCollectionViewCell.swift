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
    
    @IBOutlet private var lowSensitivityButton: GazeableSegmentedButton!
    @IBOutlet private var mediumSensitivityButton: GazeableSegmentedButton!
    @IBOutlet private var highSensitivityButton: GazeableSegmentedButton!
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        AppConfig.$cursorSensitivity.sink { (sensitivity) in
            self.lowSensitivityButton.isSelected = false
            self.mediumSensitivityButton.isSelected = false
            self.highSensitivityButton.isSelected = false
            
            switch sensitivity {
            case .low:
                self.lowSensitivityButton.isSelected = true
            case .medium:
                self.mediumSensitivityButton.isSelected = true
            case .high:
                self.highSensitivityButton.isSelected = true
            }
        }.store(in: &disposables)
    }
    
    @IBAction private func handleLowSensitivity(_ sender: Any) {
        AppConfig.cursorSensitivity = .low
    }
    
    @IBAction private func handleMediumSensitivity(_ sender: Any) {
        AppConfig.cursorSensitivity = .medium
    }
    
    @IBAction private func handleHighSensitivity(_ sender: Any) {
        AppConfig.cursorSensitivity = .high
    }
}
