//
//  PaginationCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit
import Combine

class PaginationCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet weak var paginationLabel: UILabel!
    private var disposables = Set<AnyCancellable>()
    
    var paginationDirection: UIPageViewController.NavigationDirection = .forward {
        didSet {
            updatePaginationLabel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        _ = ItemSelection.$presetsPageIndicatorProgress.sink(receiveValue: { newValue in
            if newValue.pageCount <= 1 {
                self.borderedView.alpha = 0.5
            } else {
                self.borderedView.alpha = 1.0
            }
        }).store(in: &self.disposables)
        
        updatePaginationLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        paginationLabel.text = nil
    }
    
    override func updateContentViews() {
        super.updateContentViews()
        borderedView.fillColor = isSelected ? .cellSelectionColor : fillColor
    }
    
    private func updatePaginationLabel() {
        let image: UIImage!
        
        switch paginationDirection {
        case .forward:
            image = UIImage(systemName: "chevron.right")
        case .reverse:
            image = UIImage(systemName: "chevron.left")
        @unknown default:
            return
        }
        
        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSMutableAttributedString(attachment: systemImageAttachment)
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 48)], range: NSRange(location: 0, length: attributedString.length))
        paginationLabel.attributedText = attributedString
    }
    
}
