//
//  AddPhraseCollectionViewCell.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import UIKit

class AddPhraseCollectionViewCell: VocableCollectionViewCell {
    private let textLabel = UILabel(frame: .zero)

    private let dashedBorderView = CAShapeLayer()

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

        borderedView.isHidden = true

        dashedBorderView.strokeColor = UIColor.categoryBackgroundColor.cgColor
        dashedBorderView.lineDashPattern = [6, 6]
        dashedBorderView.fillColor = nil
        dashedBorderView.lineWidth = 6
        contentView.layer.addSublayer(dashedBorderView)

        textLabel.attributedText = .addPhraseTitle
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)

        let layoutGuide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            textLabel.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor).withPriority(999),
            textLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            textLabel.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            textLabel.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).withPriority(999)
        ])

        updateContentViews()
    }

    override func updateContentViews() {
        super.updateContentViews()

        if isHighlighted && !isSelected {
            dashedBorderView.strokeColor = UIColor.cellBorderHighlightColor.cgColor
        } else if isSelected {
            dashedBorderView.strokeColor = nil
        } else {
            dashedBorderView.strokeColor = UIColor.categoryBackgroundColor.cgColor
        }

        textLabel.textColor = isSelected ? .selectedTextColor : .defaultTextColor
        dashedBorderView.fillColor = isSelected ? UIColor.cellSelectionColor.cgColor : nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedBorderView.frame = bounds
        dashedBorderView.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
    }
}

private extension NSAttributedString {
    static var addPhraseTitle: NSAttributedString {
        let text = NSLocalizedString("preset.category.add.phrase.title", comment: "Add phrase button title")
        let image = UIImage(systemName: "plus")!
        let font: UIFont = (UITraitCollection.current.horizontalSizeClass == .regular
                            && UITraitCollection.current.verticalSizeClass == .regular)
                            ? UIFont.systemFont(ofSize: 28, weight: .bold)
                            : UIFont.systemFont(ofSize: 22, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return NSAttributedString.imageAttachedString(for: text, with: image, attributes: attributes)
    }
}
