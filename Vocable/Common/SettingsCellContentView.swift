//
//  SettingsCellContentView.swift
//  Vocable
//
//  Created by Jesse Morgan on 3/14/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

private final class GazeableAccessoryButton: GazeableButton {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        if [traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass].contains(.compact) {
            return CGSize(width: 56, height: 48)
        }
        return CGSize(width: 100, height: 104)
    }
}

final class SettingsCellContentView: UIView, UIContentView {

    // MARK: - Subviews

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    // MARK: - Properties

    var configuration: UIContentConfiguration

    // MARK: - Lifecycle

    init(configuration: SettingsCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = nil
        addSubview(stackView)
        stackView.constrain(fill: self)
        configure(with: configuration)
    }

    private func configure(with configuration: UIContentConfiguration) {
        guard let configuration = configuration as? SettingsCellContentConfiguration else { return }

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        print(configuration.accessories)
        configuration.accessories.map { accessory -> UIButton in
            let button = GazeableButton()
            button.setImage(accessory.image, for: .normal)
            return button
        }.forEach { stackView.addArrangedSubview($0) }

        stackView.arrangedSubviews.forEach {
            $0.constrain(toHeightOf: self)
            $0.constrain(aspectRatio: 1)
        }

        let labelButton = GazeableButton()
        stackView.addArrangedSubview(labelButton)
        labelButton.setAttributedTitle(configuration.attributedText, for: .normal)
        labelButton.contentHorizontalAlignment = .left
        labelButton.contentEdgeInsets = .init(uniform: 16)
        labelButton.constrain(toHeightOf: stackView)
    }
}
