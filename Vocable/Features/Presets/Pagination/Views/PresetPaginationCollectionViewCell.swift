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
            self?.isEnabled = (pageProgress.pageCount > 1)
        }).store(in: &self.disposables)
    }
    
}
