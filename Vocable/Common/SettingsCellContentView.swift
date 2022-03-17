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

    var configuration: UIContentConfiguration {
        didSet {
            configure(with: configuration)
        }
    }

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

        // TODO: guard against configuration changes
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        configuration.accessories.map { accessory -> UIButton in
            let button = GazeableButton()
            button.setImage(accessory.image, for: .normal)
            button.addAction(UIAction(title: "Accessory action", handler: { _ in
                guard let action = accessory.action else { return }
                action()
            }), for: .touchUpInside)
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
        // TODO: better handle disclosure image
        labelButton.setTrailingImage(image: UIImage(systemName: "chevron.right"), offset: 24)
        labelButton.addAction(UIAction(title: "Cell action", handler: { _ in
            configuration.cellAction()
        }), for: .touchUpInside)
        labelButton.constrain(toHeightOf: stackView)
    }
}
