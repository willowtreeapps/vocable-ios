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
        let text = "This category has no phrases yet"
        let buttonTitle = "Add Phrase"
        super.init(text: text, action: (title: buttonTitle, action: action))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
