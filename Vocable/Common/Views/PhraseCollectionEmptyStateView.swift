//
//  PhraseCollectionEmptyStateView.swift
//  Vocable
//
//  Created by Chris Stroud on 4/21/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class PhraseCollectionEmptyStateView: EmptyStateView {

    init(action: @escaping () -> Void) {
        let text = NSLocalizedString("empty_state.header.title", comment: "Empty state title")
        let buttonTitle = NSLocalizedString("empty_state.button.title", comment: "Empty state Add Phrase button title")
        super.init(headerText: text, action: (title: buttonTitle, action: action))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
