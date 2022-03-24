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

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var decreaseTimeButton: GazeableButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var increaseTimeButton: GazeableButton!
    
    @IBOutlet var topSeparator: UIView!
    @IBOutlet var bottomSeparator: UIView!
    
    private var disposables = Set<AnyCancellable>()

    private static let secondsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .second
        formatter.allowsFractionalUnits = true
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    private static func formattedString(forDuration duration: TimeInterval) -> String {

        // Prospective workaround for http://www.openradar.me/32024200
        //
        // This code rounds the value up to the nearest integer
        // and formats with DateComponents before doing (hopefully)
        // a sufficiently locale-aware number replacement with the
        // actual value as formatted in accordance with the user's locale by NumberFormatter
        //
        // This is an attempt to avoid having to do an full-fledged stringsdict
        // just to handle pluralization and general formatting of a "# of seconds" string.

        let roundedValue = duration.rounded(.up) // Rounding up so plurality rules apply
        let formattedComponents = secondsFormatter.string(from: roundedValue)!
        let separator = Locale.current.decimalSeparator ?? "."
        let expression = try! NSRegularExpression(pattern: "\\d\\\(separator)?\\d?", options: [.dotMatchesLineSeparators])
        let range = formattedComponents.startIndex ..< formattedComponents.endIndex
        guard let match = expression.firstMatch(in: formattedComponents,
                                          options: [],
                                          range: NSRange(range, in: formattedComponents)) else {
                                            return ""
        }
        guard let formattedValue = numberFormatter.string(for: duration) else { return "" }
        let lower = formattedComponents.index(formattedComponents.startIndex, offsetBy: match.range.lowerBound)
        let upper = formattedComponents.index(formattedComponents.startIndex, offsetBy: match.range.upperBound)
        let substituted = formattedComponents.replacingCharacters(in: lower ..< upper, with: formattedValue)
        return substituted
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = NSLocalizedString("timing_and_sensitivity.cell.dwell_duration.title", comment: "Dwell duration configuration option name")
        AppConfig.$selectionHoldDuration.sink(receiveValue: { [weak self] duration in
            self?.timeLabel.text = DwellTimeCollectionViewCell.formattedString(forDuration: duration)
        }).store(in: &disposables)
    }
    
}
