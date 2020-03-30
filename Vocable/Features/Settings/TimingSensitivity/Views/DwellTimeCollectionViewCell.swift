//
//  DwellTimeCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/26/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class DwellTimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var decreaseTimeButton: GazeableButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var increaseTimeButton: GazeableButton!
    
    private var disposables = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        AppConfig.$selectionHoldDuration.sink(receiveValue: { duration in
            // Only show decimal if number is not whole number (e.g. "1s" & "0.5s")
            let durationFormatted = duration.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", duration) : String(duration)
            self.timeLabel.text = NSLocalizedString("\(durationFormatted)s", comment: "Hover time seconds label")
        }).store(in: &disposables)
    }
    
}
