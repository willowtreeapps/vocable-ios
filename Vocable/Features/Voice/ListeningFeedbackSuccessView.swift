//
//  ListeningFeedbackSuccessView.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

final class ListeningFeedbackSuccessView: UIView {

    // MARK: Properties

    private let label = UILabel()

    // MARK: Initializers

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let font: UIFont = sizeClass == .hRegular_vRegular
                           ? .systemFont(ofSize: 34, weight: .bold)
                           : .systemFont(ofSize: 22, weight: .bold)
        let symbol = UIImage(systemName: "checkmark.circle.fill")!.withTintColor(.cellSelectionColor)

        let text = String(localized: "listening_mode.feedback.confirmation.title")
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.defaultTextColor]
        label.attributedText = NSAttributedString.imageAttachedString(for: text, with: symbol, attributes: attributes)

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                                     label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }
}
