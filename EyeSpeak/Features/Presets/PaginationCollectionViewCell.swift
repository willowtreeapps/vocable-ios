//
//  PaginationCollectionViewCell.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/18/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PaginationCollectionViewCell: VocableCollectionViewCell {
    
    @IBOutlet weak var paginationLabel: UILabel!
    
    var paginationDirection: PaginationDirection = .forward {
        didSet {
            updatePaginationLabel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updatePaginationLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        paginationLabel.text = nil
    }
    
    override func updateContentViews() {
        super.updateContentViews()
        borderedView.fillColor = isSelected ? .cellSelectionColor : .categoryBackgroundColor
    }
    
    private func updatePaginationLabel() {
        let image: UIImage!
        
        switch paginationDirection {
        case .forward:
            image = UIImage(systemName: "chevron.right")
        case .backward:
            image = UIImage(systemName: "chevron.left")
        }
        
        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSMutableAttributedString(attachment: systemImageAttachment)
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 48)], range: NSRange(location: 0, length: attributedString.length))
        paginationLabel.attributedText = attributedString
    }
    
}
