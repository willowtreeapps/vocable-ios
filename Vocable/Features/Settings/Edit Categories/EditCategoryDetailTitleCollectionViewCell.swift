//
//  EditCategoryDetailsHeaderCollectionViewCell.swift
//  Vocable AAC
//
//  Created by Steve Foster on 5/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

protocol EditCategoryDetailTitleCollectionViewCellDelegate: class {
    func didTapEdit()
}

final class EditCategoryDetailTitleCollectionViewCell: UICollectionViewCell {

    weak var delegate: EditCategoryDetailTitleCollectionViewCellDelegate?

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var editButton: GazeableButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        editButton.backgroundColor = .collectionViewBackgroundColor
        editButton.setFillColor(.defaultCellBackgroundColor, for: .normal)
        editButton.setTitleColor(.defaultTextColor, for: .normal)
        editButton.isOpaque = true
    }

    @IBAction func didTapEdit(_ sender: Any) {
        delegate?.didTapEdit()
    }

}
