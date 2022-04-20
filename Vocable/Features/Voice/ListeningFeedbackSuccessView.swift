//
//  ListeningFeedbackSuccessView.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Combine
import UIKit

final class ListeningFeedbackSuccessView: UIView {

    typealias UserDefaults = ListeningFeedbackUserDefaults

    // MARK: Properties

    private let label = UILabel()

    @PublishedDefault(key: UserDefaults.submitConfirmationText.key, defaultValue: UserDefaults.submitConfirmationText.defaultStringValue)
    private var submitConfirmationText
    private var disposables = Set<AnyCancellable>()

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
        updateText()

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
                                     label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }

    private func setupTextPublisher() {
        $submitConfirmationText
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateText()
            }).store(in: &disposables)
    }

    private func updateText() {
        let font: UIFont = sizeClass == .hRegular_vRegular
                           ? .systemFont(ofSize: 34, weight: .bold)
                           : .systemFont(ofSize: 22, weight: .bold)
        let symbol = UIImage(systemName: "checkmark.circle.fill")!.withTintColor(.cellSelectionColor)

        // TODO: localize and finalize copy
        let text = submitConfirmationText
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        label.attributedText = NSAttributedString.imageAttachedString(for: text, with: symbol, attributes: attributes)
    }
}
