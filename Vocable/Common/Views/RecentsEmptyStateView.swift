//
//  RecentsEmptyStateView.swift
//  Vocable
//
//  Created by Caroline Law on 10/12/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import UIKit

class RecentsEmptyStateView: EmptyStateView {

    init() {
        let title = NSLocalizedString("recents_empty_state.header.title", comment: "Recents empty state title")
        let body = NSLocalizedString("recents_empty_state.body.title", comment: "Recents empty state body")
        let text = NSAttributedString(string: title, attributes: [.font: UIFont.boldSystemFont(ofSize: 24), .foregroundColor: UIColor.defaultTextColor])
        let image = UIImage(named: "recents")
        let extraText = NSAttributedString(string: body, attributes: [.foregroundColor: UIColor.defaultTextColor])
        super.init(attributedText: text, image: image, extraAttributedText: extraText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
