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

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var lowSensitivityButton: GazeableSegmentedButton!
    @IBOutlet private weak var mediumSensitivityButton: GazeableSegmentedButton!
    @IBOutlet private weak var highSensitivityButton: GazeableSegmentedButton!

    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.text = NSLocalizedString("timing_and_sensitivity.cell.cursor_sensitivity.title",
                                            comment: "Cursor sensitivity configuration option name")

        let lowTitle = NSLocalizedString("timing_and_sensitivity.button.low.title",
                                         comment: "Low cursor sensitivity option button")

        let mediumTitle = NSLocalizedString("timing_and_sensitivity.button.medium.title",
                                            comment: "Medium cursor sensitivity option button")

        let highTitle = NSLocalizedString("timing_and_sensitivity.button.high.title",
                                          comment: "High cursor sensitivity option button")

        lowSensitivityButton.setTitle(lowTitle, for: .normal)
        mediumSensitivityButton.setTitle(mediumTitle, for: .normal)
        highSensitivityButton.setTitle(highTitle, for: .normal)

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
