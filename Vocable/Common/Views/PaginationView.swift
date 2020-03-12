//
//  PaginationView.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class PaginationView: UIView {

    @IBOutlet var labelText: UILabel!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var previousPageButton: GazeableButton!
    @IBOutlet var nextPageButton: GazeableButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "PaginationView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
