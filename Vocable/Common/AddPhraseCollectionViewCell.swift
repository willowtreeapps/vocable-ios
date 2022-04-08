//
//  AddPhraseCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

class AddPhraseCollectionViewCell: VocableCollectionViewCell {
    let textLabel = UILabel(frame: .zero)

    let dashedBorderView = CAShapeLayer()

    override func updateContentViews() {
        super.updateContentViews()

        dashedBorderView.strokeColor = isHighlighted ? nil : UIColor.categoryBackgroundColor.cgColor

        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        textLabel.backgroundColor = .clear
        textLabel.isOpaque = true
        textLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        contentView.preservesSuperviewLayoutMargins = true

        fillColor = .clear

        dashedBorderView.strokeColor = UIColor.categoryBackgroundColor.cgColor
        dashedBorderView.lineDashPattern = [8, 6]
        dashedBorderView.frame = bounds
        dashedBorderView.fillColor = nil
        dashedBorderView.lineWidth = 6
        dashedBorderView.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
        layer.addSublayer(dashedBorderView)

        let text = NSLocalizedString("preset.category.add.phrase.title", comment: "Add phrase button title")
        let image = UIImage(systemName: "plus")!
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22, weight: .bold)]
        textLabel.attributedText = NSAttributedString.imageAttachedString(for: text, with: image, attributes: attributes)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)

        // Needs a weak spot that can break while resizing to avoid
        // constraint errors
        let rightConstraint = textLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
        rightConstraint.priority = .init(999)

        let bottomConstraint = textLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = .init(999)
        NSLayoutConstraint.activate([
            rightConstraint,
            textLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            bottomConstraint
        ])

        updateContentViews()
    }

    func setup(title: String) {
        textLabel.text = title
        updateContentViews()
    }

    func setup(with image: UIImage?) {
        guard let image = image else {
            return
        }

        let systemImageAttachment = NSTextAttachment(image: image)
        let attributedString = NSAttributedString(attachment: systemImageAttachment)

        textLabel.attributedText = attributedString
        updateContentViews()
    }
}
