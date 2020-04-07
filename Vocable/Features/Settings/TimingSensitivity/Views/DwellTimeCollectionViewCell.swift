//
//  DwellTimeCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

final class DwellTimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var decreaseTimeButton: GazeableButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var increaseTimeButton: GazeableButton!
    
    @IBOutlet var topSeparator: UIView!
    @IBOutlet var bottomSeparator: UIView!
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        AppConfig.$selectionHoldDuration.sink(receiveValue: { [weak self] duration in
            // Only show decimal if number is not whole number (e.g. "1s" & "0.5s")
            let durationFormatted = duration.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", duration) : String(duration)
            self?.timeLabel.text = String.localizedStringWithFormat(NSLocalizedString("%@s", comment: "Dwell duration"), durationFormatted)
        }).store(in: &disposables)
    }
    
}
