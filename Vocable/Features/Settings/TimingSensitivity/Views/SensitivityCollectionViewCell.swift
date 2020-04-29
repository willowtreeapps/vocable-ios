//
//  SensitivityCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

final class SensitivityCollectionViewCell: UICollectionViewCell {
    
    private var disposables = Set<AnyCancellable>()

    @IBOutlet private weak var lowSensitivityButton: GazeableSegmentedButton!
    @IBOutlet private weak var mediumSensitivityButton: GazeableSegmentedButton!
    @IBOutlet private weak var highSensitivityButton: GazeableSegmentedButton!

    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!

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
