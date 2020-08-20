//
//  EditCategoryDetailsHeaderCollectionViewCell.swift
//  Vocable
//
//  Created by Steve Foster on 5/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

protocol EditCategoryDetailsHeaderCollectionViewCellDelegate: class {
    func didTapEdit()
}

final class EditCategoryDetailTitleCollectionViewCell: UICollectionViewCell {

    weak var delegate: EditCategoryDetailsHeaderCollectionViewCellDelegate?

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var editButton: GazeableButton!

    @IBAction func didTapEdit(_ sender: Any) {
        delegate?.didTapEdit()
    }

}
