//
//  VocableCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

/// A data item presented with Vocable styling
class VocableCollectionViewCell: UICollectionViewCell {
    
    let borderedView = BorderedView()
    
    var fillColor: UIColor = .defaultCellBackgroundColor {
        didSet {
            updateContentViews()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateContentViews()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateContentViews()
        }
    }

    var isEnabled: Bool = true {
        didSet {
            updateContentViews()
        }
    }
    
    fileprivate var defaultBackgroundColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        updateContentViews()
        backgroundView = borderedView
    }
    
    func updateContentViews() {

        let fillColor: UIColor = {
            if isSelected {
                return .cellSelectionColor
            }
            if !isEnabled {
                return self.fillColor.withAlphaComponent(0.5)
            }
            return self.fillColor
        }()

        borderedView.cornerRadius = 8
        borderedView.borderColor = .cellBorderHighlightColor
        borderedView.backgroundColor = .collectionViewBackgroundColor
        borderedView.borderWidth = (isHighlighted && !isSelected) ? 4 : 0
        borderedView.fillColor = fillColor
        borderedView.isOpaque = true
    }

}
