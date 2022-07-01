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

        titleLabel.text = String(localized: "timing_and_sensitivity.cell.cursor_sensitivity.title")

        let lowTitle = String(localized: "timing_and_sensitivity.button.low.title")

        let mediumTitle = String(localized: "timing_and_sensitivity.button.medium.title")

        let highTitle = String(localized: "timing_and_sensitivity.button.high.title")

        lowSensitivityButton.setTitle(lowTitle, for: .normal)
        mediumSensitivityButton.setTitle(mediumTitle, for: .normal)
        highSensitivityButton.setTitle(highTitle, for: .normal)
        
        lowSensitivityButton.accessibilityID = .settings.timingAndSensitivity.lowSensitivityButton
        mediumSensitivityButton.accessibilityID = .settings.timingAndSensitivity.mediumSensitivityButton
        highSensitivityButton.accessibilityID = .settings.timingAndSensitivity.highSensitivityButton

        AppConfig.$cursorSensitivity.sink { [weak self] (sensitivity) in
            guard let self = self else { return }
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
        Analytics.shared.track(.cursorSensitivityChanged)
    }
    
    @IBAction private func handleMediumSensitivity(_ sender: Any) {
        AppConfig.cursorSensitivity = .medium
        Analytics.shared.track(.cursorSensitivityChanged)
    }
    
    @IBAction private func handleHighSensitivity(_ sender: Any) {
        AppConfig.cursorSensitivity = .high
        Analytics.shared.track(.cursorSensitivityChanged)
    }
}
