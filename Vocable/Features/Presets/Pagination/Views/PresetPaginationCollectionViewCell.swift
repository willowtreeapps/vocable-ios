//
//  PaginationCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class PresetPaginationCollectionViewCell: PaginationCollectionViewCell {
    
    private var disposables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        _ = ItemSelection.$presetsPageIndicatorProgress.sink(receiveValue: { [weak self] pageProgress in
            var isDisabled = false
            // If there is only one page disable both pagination buttons
            if pageProgress.pageCount <= 1 {
                isDisabled = true
            }
            self?.borderedView.alpha = CGFloat(isDisabled ? 0.5 : 1.0)
            // Makes selection color not green when button is disabled
            if let isSelected = self?.isSelected, isSelected, let fillColor = self?.fillColor {
                self?.borderedView.fillColor = isDisabled ? fillColor : .cellSelectionColor
            }
        }).store(in: &self.disposables)
        fillColor = .defaultCellBackgroundColor
    }
    
}
